import os
import re
from collections import OrderedDict

import jinja2

VERSION = "0.1.0"

TMPL_ENV = jinja2.Environment(
    loader=jinja2.FileSystemLoader("utils/templates"),
    autoescape=jinja2.select_autoescape(),
    trim_blocks=True,
    lstrip_blocks=True,
)

LOAD_ORDER = [
    "global-variables",
    "global-functions",
    "global-functions.array",
    "global-functions.string",
    "global-functions.datetime",
    "global-functions.package",
    "global-functions.misc",
    "global-helpers",
]

ESSENTIAL_PACKAGE_LIST = [
    "global-variables",
    "global-functions",
    "global-functions.array",
    "global-functions.string",
    "global-functions.datetime",
    "global-functions.package",
    "global-functions.misc",
    "tool.http",
    "tool.remote",
    "rspm.state",
    "rspm",
]


class PackageInfoGenerator:
    """PackageInfoGenerator
    automatically generate `package-list.rsc` in `res` folder from metainfo of each package.
    """
    def __init__(self):
        self.parsed = False
        self.meta_mapping = None
        self.meta_ext_mapping = {
            "rspm.hello-world": {
                "name": "rspm.hello-world",
                "version": "1.0.0",
                "author": "rspm",
                "url": "https://raw.githubusercontent.com/Detavern/rspm-pkg-hello-world/master/hello-world.rsc",
            }
        }

    def parse_folder(self, path):
        print(f'Parsing resource file from folder: {path}')
        meta_list = []
        for p in os.listdir(path):
            metainfo = self.parse_file(os.path.abspath(os.path.join(path, p)))
            meta_list.append(metainfo)
        # sort
        from pprint import pprint
        meta_mapping = {v['name']: v for v in meta_list}
        meta_mapping_sorted = OrderedDict()
        for name in LOAD_ORDER:
            if name in meta_mapping:
                meta_mapping_sorted[name] = meta_mapping[name]
                meta_mapping[name] = None
        for k, v in meta_mapping.items():
            if v is not None:
                meta_mapping_sorted[k] = v
        # save
        self.parsed = True
        self.meta_mapping = meta_mapping_sorted

    def parse_file(self, path):
        with open(path) as f:
            content = f.readlines()
            # find return
            for line in content:
                res = re.findall("^:return \$([a-zA-Z0-9_]+?);$", line)
                if res:
                    break
            else:
                raise ValueError("package info not found")
            var_name = res[0]
            # find file->package
            package_array = self.find_array(var_name, content)
            # find file->package->metaInfo
            var_name = package_array['metaInfo'][1:]
            metainfo_array = self.find_array(var_name, content)
        return metainfo_array

    def find_array(self, name, content):
        array = {}
        for i, line in enumerate(content):
            res = re.findall(f"^:local {name} {{", line)
            if res:
                break
        else:
            raise ValueError(f"array: {name} not found")
        cursor = i + 1
        while True:
            line = content[cursor]
            if line == "}\n" or line == "};\n":
                break
            else:
                res = re.findall('^\s*"([a-zA-Z0-9_]+?)"="?(.*?)"?;?\n$', line)
                if not res:
                    raise ValueError(f"array: {name} is not a key-value array")
                # split
                kv = res[0]
                array[kv[0]] = kv[1]
            cursor += 1
        return array

    def generate_package_info(self, path, filename="package-info.rsc", exclude_list=None):
        if self.parsed is False:
            raise ValueError("not parsed, use parse_folder to parse it first")
        print(f'Generating {filename} at: {path}')
        exclude_list = [] if exclude_list is None else exclude_list
        # render template
        package_mapping = OrderedDict()
        for k, v in self.meta_mapping.items():
            if k not in exclude_list:
                package_mapping[k] = v
        essential_package_list = []
        for v in ESSENTIAL_PACKAGE_LIST:
            if v not in exclude_list:
                essential_package_list.append(v)
        tmpl = TMPL_ENV.get_template("package-info.rsc.j2")
        text = tmpl.render(
            package_mapping=package_mapping,
            essential_package_list=essential_package_list,
        )
        fp = os.path.join(path, filename)
        with open(fp, 'w') as f:
            f.write(text)

    def generate_package_info_ext(self, path, filename="package-info-ext.rsc", exclude_list=None):
        if self.parsed is False:
            raise ValueError("not parsed, use parse_folder to parse it first")
        print(f'Generating {filename} at: {path}')
        exclude_list = [] if exclude_list is None else exclude_list
        # render template
        package_mapping = OrderedDict()
        for k, v in self.meta_mapping.items():
            if k not in exclude_list:
                package_mapping[k] = v
        tmpl = TMPL_ENV.get_template("package-info-ext.rsc.j2")
        text = tmpl.render(
            package_mapping=package_mapping,
        )
        fp = os.path.join(path, filename)
        with open(fp, 'w') as f:
            f.write(text)

    def generate_startup(self, path, filename="startup.rsc"):
        if self.parsed is False:
            raise ValueError("not parsed, use parse_folder to parse it first")
        print(f'Generating {filename} at: {path}')
        # make framework script list
        # - filter `essential package list` with global == 'true'
        # - replace '.' with '_'
        framework_script_list = []
        for name in ESSENTIAL_PACKAGE_LIST:
            is_global = self.meta_mapping[name].get("global") == 'true'
            if is_global:
                framework_script_list.append(name.replace('.', '_'))
        # render template
        tmpl = TMPL_ENV.get_template("startup.rsc.j2")
        text = tmpl.render(
            framework_script_list=framework_script_list,
        )
        fp = os.path.join(path, filename)
        with open(fp, 'w') as f:
            f.write(text)

    def generate_version(self, path, filename="version.rsc"):
        if self.parsed is False:
            raise ValueError("not parsed, use parse_folder to parse it first")
        print(f'Generating {filename} at: {path}')
        # render template
        tmpl = TMPL_ENV.get_template("version.rsc.j2")
        text = tmpl.render(
            version=VERSION,
        )
        fp = os.path.join(path, filename)
        with open(fp, 'w') as f:
            f.write(text)

    def generate_all(self, path, exclude_list=None):
        # check path
        if os.path.isdir(path) is False:
            os.mkdir(path)
        # generate
        self.generate_package_info(path, exclude_list=exclude_list)
        self.generate_package_info_ext(path, exclude_list=exclude_list)
        self.generate_startup(path)
        self.generate_version(path)
