import json
import yaml
import datetime

from .utils import TMPL_ENV


class ObjectDumper:
    TOKEN_INDENT = " "
    TOKEN_DELIMITER = ";"
    TOKEN_NIL = "$Nil"
    TOKEN_TRUE = "true"
    TOKEN_FALSE = "false"
    TOKEN_EMPTY_ARRAY = "{}"
    TOKEN_STR_NEED_PAREN = {'$'}
    TOKEN_STR_ESCAPE_MAP = {
        '"': '\\"',
        '\\': '\\\\',
        '$': '\\$',
        '?': '\\?',
    }

    def __init__(self, obj, indent=0):
        self._obj = obj
        self._indent = indent

    @classmethod
    def from_json_string(cls, js, indent=0):
        obj = json.loads(js)
        return cls(obj, indent)

    @classmethod
    def from_json_file(cls, fp, indent=0):
        with open(fp) as f:
            obj = json.load(f)
            return cls(obj, indent)

    @classmethod
    def from_yaml(cls, fp, indent=0):
        with open(fp) as f:
            obj = yaml.safe_load(f)
            return cls(obj, indent)

    def dumps(self):
        return self.format_switch(self._obj)

    def make_indent(self, level=0):
        if self._indent <= 0:
            return ''

        indent = self.TOKEN_INDENT * self._indent * level
        return f'\r\n{indent}'

    def format_switch(self, obj, indent_level=0):
        if obj is None:
            return self.TOKEN_NIL
        elif isinstance(obj, bool):
            return self.TOKEN_TRUE if obj else self.TOKEN_FALSE
        elif isinstance(obj, str):
            return self.format_str(obj)
        elif isinstance(obj, int):
            return str(obj)
        elif isinstance(obj, float):
            return str(obj)
        elif isinstance(obj, dict):
            return self.format_dict(obj, indent_level)
        elif isinstance(obj, (list, tuple)):
            return self.format_list(obj, indent_level)
        else:
            raise ValueError(f"unknown type: {type(obj)}")

    def format_str(self, obj):
        v = ''
        need_paren = False
        for ch in obj:
            if ord(ch) > 127:
                # TODO: add unicode support
                raise ValueError("only support ASCII currently")
            if ch in self.TOKEN_STR_NEED_PAREN and not need_paren:
                need_paren = True
            if ch in self.TOKEN_STR_ESCAPE_MAP:
                v = f'{v}{self.TOKEN_STR_ESCAPE_MAP[ch]}'
            else:
                v = f'{v}{ch}'

        if need_paren:
            return f'("{v}")'
        return f'"{v}"'

    def format_dict(self, obj, indent_level):
        if not obj:
            return self.TOKEN_EMPTY_ARRAY

        result = "{"
        for k, v in obj.items():
            result = f"{result}{self.make_indent(indent_level+1)}"
            # make k=v
            result = f"{result}{self.format_str(k)}={self.format_switch(v, indent_level+1)}"
            # delimiter
            result = f"{result}{self.TOKEN_DELIMITER}"
        result = f"{result}{self.make_indent(indent_level)}}}"
        return result

    def format_list(self, obj, indent_level):
        if not obj:
            return self.TOKEN_EMPTY_ARRAY

        result = "{"
        for v in obj:
            result = f"{result}{self.make_indent(indent_level+1)}"
            # make v
            result = f"{result}{self.format_switch(v, indent_level+1)}"
            # delimiter
            result = f"{result}{self.TOKEN_DELIMITER}"
        result = f"{result}{self.make_indent(indent_level)}}}"
        return result

    def to_configuration(self, dst, package_name, package_desc=None):
        tmpl = TMPL_ENV.get_template("config.rsc.j2")
        ctn = self.dumps()
        data = {"deployment": ctn}
        desc = package_desc if package_desc else package_name
        now = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
        text = tmpl.render(
            package_name=package_name,
            package_desc=desc,
            created_at=now,
            last_modify=now,
            data=data,
        )
        with open(dst, 'w') as f:
            f.write(text)
