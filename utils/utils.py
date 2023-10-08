import os

import jinja2

BASE_PATH = os.path.dirname(__file__)
TMPL_ENV = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.join(BASE_PATH, "templates")),
    autoescape=jinja2.select_autoescape(),
    trim_blocks=True,
    lstrip_blocks=True,
)

SPECIAL_PACKAGE_SUFFIX = ['.cfg']


def get_package_name(path: os.PathLike) -> str:
    file_name = os.path.basename(path)
    script_name, _ = os.path.splitext(file_name)
    # special suffix
    for suffix in SPECIAL_PACKAGE_SUFFIX:
        if script_name.endswith(suffix):
            script_name = script_name[:-len(suffix)]
    pkg_name = script_name.replace("_", ".")
    return pkg_name


def get_script_name(path: os.PathLike) -> str:
    file_name = os.path.basename(path)
    script_name, _ = os.path.splitext(file_name)
    return script_name
