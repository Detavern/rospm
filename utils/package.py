import os
import re
from collections import OrderedDict

import yaml
import jinja2

from .parser import PackageParser

with open(os.path.join("utils", "config.yml")) as f:
    config = yaml.safe_load(f)

TMPL_ENV = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.join("utils", "templates")),
    autoescape=jinja2.select_autoescape(),
    trim_blocks=True,
    lstrip_blocks=True,
)

VERSION = config['version']

LOAD_ORDER = config['load_order']

ESSENTIAL_PACKAGE_LIST = config['essential_package_list']


class PackageResourceGenerator:
    """PackageResourceGenerator
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
            pp = PackageParser.from_file(os.path.abspath(os.path.join(path, p)))
            node = pp.get_metainfo()
            meta_list.append(node.value)
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
        for k, v in self.meta_ext_mapping.items():
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
            is_global = self.meta_mapping[name].get("global", False)
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


class PackageMetainfoModifier:
    """PackageMetainfoModifier
    Modify package's meta info
    """
    def __init__(self):
        pass

    def bump_version(self, path):
        print(f'Parsing library file from folder: {path}')
        for p in os.listdir(path):
            if p.endswith(".rsc"):
                fp = os.path.abspath(os.path.join(path, p))
                pp = PackageParser.from_file(fp)
                node = pp.get_metainfo()
                metainfo = node.value
                self.update_version(metainfo)
                self.do_update(fp, node, metainfo)

    def do_update(self, path, node, metainfo):
        with open(path, 'rb') as f:
            content = f.read()
        ct = content[:node.start] + self.make_metainfo(metainfo).encode() + content[node.end:]
        with open(path, 'wb') as f:
            f.write(ct)

    def update_version(self, metainfo):
        metainfo['version'] = VERSION

    def update_global_functions(self, metainfo, pp):
        metainfo.pop('global-functions', None)
        func_list = [i.name for i in pp.get_global_functions()]
        if func_list:
            metainfo['global-functions'] = func_list

    def update_global_variables(self, metainfo, pp):
        metainfo.pop('global-variables', None)
        var_list = [i.name for i in pp.get_global_variables()]
        if var_list:
            metainfo['global-variables'] = var_list

    def check_exec(self, metainfo, pp):
        name = metainfo['name']
        cmd_list = pp.get_global_commands()
        if cmd_list:
            cmd = cmd_list[0].value
            raise ValueError(f"package: {name} contain executable command: {cmd}")

    def update_metainfo(self, path, ignore_exec_check: list):
        print(f'Parsing library file from folder: {path}')
        for p in os.listdir(path):
            if p.endswith(".rsc"):
                fp = os.path.abspath(os.path.join(path, p))
                pp = PackageParser.from_file(fp)
                node = pp.get_metainfo()
                metainfo = node.value
                self.update_version(metainfo)
                self.update_global_functions(metainfo, pp)
                self.update_global_variables(metainfo, pp)
                if metainfo['name'] not in ignore_exec_check:
                    self.check_exec(metainfo, pp)
                self.do_update(fp, node, metainfo)

    def make_metainfo(self, metainfo):
        result = [
            ':local metaInfo {',
        ]
        for k, v in metainfo.items():
            if type(v) is bool:
                result.append(f'    "{k}"={"true" if v else "false"};')
            elif type(v) is list:
                result.append(f'    "{k}"={{')
                for vv in v:
                    result.append(f'        "{vv}";')
                result.append('    };')
            else:
                result.append(f'    "{k}"="{v}";')
        result.append("};\r\n")
        string = "\r\n".join(result)
        return string
