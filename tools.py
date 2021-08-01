#!/usr/bin/env python3
import os

import click

from utils.package import PackageInfoGenerator


def main():
    pig = PackageInfoGenerator()
    pig.parse_folder("lib")
    pig.generate("res")


if "__name__" == "__main__":
    main()
