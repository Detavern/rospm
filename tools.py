#!/usr/bin/env python3
import os
import sys

import click

from utils.package import PackageResourceGenerator, PackageMetainfoModifier
from utils.quote import ScriptQuoteGenerator
from utils.dumper import ObjectDumper
from utils.utils import get_package_name


def parse_ctx_src_dst(ctx: click.Context, filename_filter=None, filename_handler=None):
    # check
    if ctx.params['src'] is None and ctx.params['src_dir'] is None:
        print("need either --src or --src-dir")
        sys.exit(1)

    if ctx.params['dst'] is None and ctx.params['dst_dir'] is None:
        print("need either --dst or --dst-dir")
        sys.exit(1)

    # generate
    targets = generate_targets(
        ctx.params, filename_filter=filename_filter, filename_handler=filename_handler)
    if len(targets) == 0:
        print("no valid target!")
        sys.exit(1)
    ctx.params["targets"] = targets

    # echo
    for t in targets:
        print(f'{t[0]} ==> {t[1]}')


def filter_script_file(filename) -> bool:
    if filename.startswith("#"):
        return False
    if not filename.endswith(".rsc"):
        return False
    return True


def filter_json_file(filename) -> bool:
    if filename.startswith("#"):
        return False
    if not filename.endswith(".json"):
        return False
    return True


def filter_yaml_file(filename) -> bool:
    if filename.startswith("#"):
        return False
    if not filename.endswith(".yaml") and not filename.endswith(".yml"):
        return False
    return True


def generate_targets(params: dict, abspath=False, filename_filter=None, filename_handler=None) -> list:
    if filename_filter is None:
        filename_filter = filter_script_file
    if filename_handler is None:
        filename_handler = os.path.basename

    targets = []
    src = params['src']
    dst = params['dst']
    src_dir = params['src_dir']
    dst_dir = params['dst_dir']

    # generate targets
    if src is not None:
        if dst is not None:
            targets.append((src, dst))
        else:
            filename = os.path.basename(src)
            targets.append((src, os.path.join(dst_dir, filename_handler(filename))))

    if src_dir is not None and dst_dir is not None:
        for filename in sorted(os.listdir(src_dir)):
            if not filename_filter(filename):
                continue
            targets.append((
                os.path.join(src_dir, filename),
                os.path.join(dst_dir, filename_handler(filename)),
            ))

    # abs
    if abspath:
        notabs, targets = targets, []
        for t in notabs:
            targets.append((os.path.abspath(t[0]), os.path.abspath(t[1])))

    return targets


@click.group()
def cli():
    pass


# cli group


@cli.group(help="Library related operations.")
def lib():
    pass


@cli.group(help="Resource related operations.")
def res():
    pass


@cli.group(help="Configuration related operations.")
def config():
    pass


@cli.group(help="Quote script files or directories")
@click.option('--src', help='source path of target file')
@click.option('--dst', help='destination path of target file')
@click.option('--src-dir', help='source path of target folder')
@click.option('--dst-dir', help='destination path of target folder')
@click.pass_context
def quote(ctx: click.Context, *_, **kwargs):
    parse_ctx_src_dst(ctx, filename_handler=ScriptQuoteGenerator.get_quoted_filename)


# lib group


@lib.command(help="Change version number of all files in lib folder.")
@click.option('--src', default='lib', help='path of lib folder')
def bump_version(src):
    abs_src = os.path.abspath(src)
    pmm = PackageMetainfoModifier()
    pmm.bump_version(abs_src)


@lib.command(help="Update metainfo of a single file.")
@click.option('--src', default='lib', help='path of lib folder')
@click.option('--filename', help='name of target file name')
def update_single_metainfo(src, filename):
    abs_src = os.path.abspath(src)
    pmm = PackageMetainfoModifier()
    pmm.update_single_metainfo(abs_src, filename)


@lib.command(help="Update metainfo of each file.")
@click.option('--src', default='lib', help='path of lib folder')
@click.option('--ignore-cmd', multiple=True, help='package name to skip executable commands check(can use multiple times)')
def update_metainfo(src, ignore_cmd):
    ignore_cmd = list(ignore_cmd)
    ignore_cmd.append("global-variables")
    abs_src = os.path.abspath(src)
    pmm = PackageMetainfoModifier()
    pmm.update_metainfo(abs_src, ignore_cmd)


# res group


@res.command(help="Generate all resources from script in library.")
@click.option('--src', default='lib', help='source path of folder to parse')
@click.option('--dst', default='res', help='destination path of parsed information folder')
@click.option('--exclude', multiple=True, help='package name to exclude(can use multiple times)')
def generate(src, dst, exclude):
    abs_src = os.path.abspath(src)
    abs_dst = os.path.abspath(dst)
    prg = PackageResourceGenerator()
    prg.parse_folder(abs_src)
    prg.generate_all(abs_dst, exclude_list=exclude)


# quote group


@quote.command(help="Quote targets into importable files.")
@click.pass_context
def as_import(ctx):
    targets = ctx.parent.params['targets']
    for target in targets:
        sqg = ScriptQuoteGenerator.from_file(target[0])
        sqg.to_importable_file(target[1], get_package_name(target[0]))


# config group


@config.command(help="Generate configurations from json files.")
@click.option('--src', help='source path of target file')
@click.option('--dst', help='destination path of target file')
@click.option('--src-dir', help='source path of target folder')
@click.option('--dst-dir', help='destination path of target folder')
@click.option('--name', help='configuration package name')
@click.pass_context
def from_json(ctx: click.Context, *_, **kwargs):
    package_name = ctx.params['name']
    if package_name is None:
        package_name = "test"

    def handler(filename):
        name, _ = os.path.splitext(filename)
        return f'{name}.cfg.rsc'

    parse_ctx_src_dst(ctx, filename_filter=filter_json_file, filename_handler=handler)

    for target in ctx.params['targets']:
        dumper = ObjectDumper.from_json_file(target[0])
        pkg_name = package_name if package_name else get_package_name(target[0])
        dumper.to_configuration(target[1], pkg_name)


@config.command(help="Generate configurations from yaml files.")
@click.option('--src', help='source path of target file')
@click.option('--dst', help='destination path of target file')
@click.option('--src-dir', help='source path of target folder')
@click.option('--dst-dir', help='destination path of target folder')
@click.option('--name', help='configuration package name')
@click.pass_context
def from_yaml(ctx: click.Context, *_, **kwargs):
    package_name = ctx.params['name']
    if package_name is None:
        package_name = "test"

    def handler(filename):
        name, _ = os.path.splitext(filename)
        return f'{name}.cfg.rsc'

    parse_ctx_src_dst(ctx, filename_filter=filter_yaml_file, filename_handler=handler)

    for target in ctx.params['targets']:
        dumper = ObjectDumper.from_yaml(target[0])
        pkg_name = package_name if package_name else get_package_name(target[0])
        dumper.to_configuration(target[1], pkg_name)


if __name__ == "__main__":
    cli()
