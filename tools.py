#!/usr/bin/env python3
import os
import sys

import click

from utils.package import PackageResourceGenerator, PackageMetainfoModifier
from utils.quote import ScriptQuoteGenerator
from utils.utils import get_package_name


def generate_targets(params: dict, abspath=False, filename_handler=None) -> list:
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
            if filename.startswith("#"):
                continue
            if not filename.endswith(".rsc"):
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


@cli.group(help="Library related operations.")
def lib():
    pass


@cli.group(help="Resource related operations.")
def res():
    pass


@cli.group(help="Quote script files or diectories")
@click.option('--src', help='source path of target file')
@click.option('--dst', help='destination path of target file')
@click.option('--src-dir', help='source path of target folder')
@click.option('--dst-dir', help='destination path of target folder')
@click.pass_context
def quote(ctx, *_, **kwargs):
    # check
    if ctx.params['src'] is None and ctx.params['src_dir'] is None:
        print("need either --src or --src-dir")
        sys.exit(1)

    if ctx.params['dst'] is None and ctx.params['dst_dir'] is None:
        print("need either --dst or --dst-dir")
        sys.exit(1)

    # generate
    targets = generate_targets(
        ctx.params, filename_handler=ScriptQuoteGenerator.get_quoted_filename)
    if len(targets) == 0:
        print("no valid target!")
        sys.exit(1)
    ctx.params["targets"] = targets

    # echo
    for t in targets:
        print(f'{t[0]} ==> {t[1]}')


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


@quote.command(help="Quote targets into importable files.")
@click.pass_context
def as_import(ctx):
    targets = ctx.parent.params['targets']
    for target in targets:
        sqg = ScriptQuoteGenerator.from_file(target[0])
        sqg.to_importable_file(target[1], get_package_name(target[0]))


if __name__ == "__main__":
    cli()
