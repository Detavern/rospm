#!/usr/bin/env python3
import os

import click

from utils.package import PackageResourceGenerator, PackageMetainfoModifier
from utils.quote import ScriptQuoteGenerator
from utils.utils import get_package_name


@click.group()
def cli():
    pass


@cli.group(help="Library related operations.")
def lib():
    pass


@cli.group(help="Resource related operations.")
def res():
    pass


@cli.group(help="Quote script file.")
def quote():
    pass


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


@quote.command(help="Quote a single script file into importable file.")
@click.option('--src', help='src file path of target file')
@click.option('--dst', help='dst file path of target file')
def as_import(src, dst):
    src = os.path.abspath(src)
    if dst is None:
        directory = os.path.dirname(src)
        fn, ext = os.path.splitext(os.path.basename(src))
        dst = os.path.join(directory, f"{fn}.quoted{ext}")
    dst = os.path.abspath(dst)
    sqg = ScriptQuoteGenerator.from_file(src)
    sqg.to_importable_file(dst, get_package_name(src))


if __name__ == "__main__":
    cli()
