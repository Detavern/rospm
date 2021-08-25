#!/usr/bin/env python3
import os

import click

from utils.package import PackageInfoGenerator


@click.group()
def cli():
    pass


@cli.group()
def resource():
    pass


@resource.command()
@click.option('--src', default='lib', help='source path of folder to parse')
@click.option('--dst', default='res', help='destination path of parsed information folder')
@click.option('--exclude', multiple=True, help='package name to exclude(can use multiple times)')
def generate(src, dst, exclude):
    abs_src = os.path.abspath(src)
    abs_dst = os.path.abspath(dst)
    pig = PackageInfoGenerator()
    pig.parse_folder(abs_src)
    pig.generate_all(abs_dst, exclude_list=exclude)


if __name__ == "__main__":
    cli()
