import io
import os

from .stream import StreamReader
from .utils import get_package_name


class TokenError(Exception):
    pass


class BaseNode:
    def __init__(self, start, end):
        self.start = start
        self.end = end

    def __repr__(self):
        cls_name = self.__class__.__name__
        return f'<{cls_name} >'


class CMDNode(BaseNode):
    def __init__(self, start, end, is_global, value):
        super().__init__(start, end)
        self.is_global = is_global
        self.value = value

    def __repr__(self):
        cls_name = self.__class__.__name__
        brief = repr(self.value)[:30]
        return f'<{cls_name} cmd={brief}>'


class FuncNode(BaseNode):
    def __init__(self, name, start, end, is_global, value):
        super().__init__(start, end)
        self.name = name
        self.is_global = is_global
        self.value = value

    def __repr__(self):
        cls_name = self.__class__.__name__
        brief = repr(self.value)[:30]
        return f'<{cls_name} name={self.name} value={brief}>'


class VarNode(BaseNode):
    def __init__(self, name, start, end, is_global, value):
        super().__init__(start, end)
        self.name = name
        self.is_global = is_global
        self.value = value

    def __repr__(self):
        cls_name = self.__class__.__name__
        brief = repr(self.value)[:30] if type(self.value) is str else self.value
        return f'<{cls_name} name={self.name} value={brief}>'


class HeaderNode(BaseNode):
    name = "header"


class CommentNode(BaseNode):
    pass


class ReturnNode(BaseNode):
    def __init__(self, start, end, value):
        super().__init__(start, end)
        self.name = 'return'
        self.value = value


class PackageParser:
    TOKEN_HEADER_END = "# Copyright (c)"
    TOKEN_COMMENT = "#"
    TOKEN_LOCAL = ":local "
    TOKEN_GLOBAL = ":global "
    TOKEN_RETURN = ":return "
    TOKEN_CMD = ":"
    TOKEN_FUNC = "do={"
    TOKEN_BRACE_END = "}"
    TOKEN_DELIMITER = ";"
    TOKEN_VAR_ARRAY = "{"
    TOKEN_VAR_ARRAY_END = "}"
    TOKEN_VAR_TRUE = "true"
    TOKEN_VAR_FALSE = "false"
    TOKEN_VAR_QUOTE = "$"
    TOKEN_VAR_BRACKET = "("
    TOKEN_VAR_BRACKET_END = ")"
    TOKEN_VAR_CMD = "["
    TOKEN_VAR_CMD_END = "]"
    TOKEN_VAR_STR_ESCAPE_MAP = {
        '"': '"',
        '\\': '\\',
        '$': '$',
        '?': '?',
        'n': '\n',
        'r': '\r',
        't': '\t',
        'a': '\a',
        'b': '\b',
        'v': '\v',
        '_': ' ',
        'f': '\xff',
    }

    def __init__(self, name: str, reader: StreamReader):
        self.name = name
        self.reader = reader
        self._nodes = []
        self._nodes_mapping = {}

    @classmethod
    def from_file(cls, path):
        inst = cls(get_package_name(path), StreamReader.from_file(path))
        inst()
        return inst

    @classmethod
    def from_string(cls, name, text):
        inst = cls(name, io.StringIO(text))
        inst()
        return inst

    def append_node(self, node):
        self._nodes.append(node)
        if hasattr(node, "name"):
            self._nodes_mapping[node.name] = node

    def __call__(self):
        # peek
        self.reader.peek()
        # parse header
        self.parse_header()
        # parse others
        while True:
            ch = self.reader.peek()
            buffered = self.reader.peek_all()
            if not ch:
                break
            # handle
            if ch in {"\n", "\r", "\t", " "}:
                self.skip_whitespace()
            # token
            elif buffered.startswith(self.TOKEN_COMMENT):
                self.parse_comment()
            elif buffered.startswith(self.TOKEN_LOCAL):
                self.parse_local()
            elif buffered.startswith(self.TOKEN_GLOBAL):
                self.parse_global()
            elif buffered.startswith(self.TOKEN_RETURN):
                self.parse_return()
            elif buffered.startswith(self.TOKEN_CMD):
                self.parse_cmd()
            else:
                raise ValueError(f"package: {self.name} unexpected token, {repr(buffered)}")

    def parse_header(self):
        start = self.reader.tell()
        ch = self.reader.peek()
        if ch in {"\n", "\r", "\t", " "}:
            self.skip_whitespace()
        while True:
            ch = self.reader.peek()
            buffered = self.reader.peek_all()
            if buffered.startswith(self.TOKEN_HEADER_END):
                # skip copyright
                self.parse_comment()
                # skip url
                self.parse_comment()
                # skip emptyß
                self.parse_comment()
                self.skip_whitespace()
                break
            elif buffered.startswith(self.TOKEN_COMMENT):
                self.parse_comment()
            else:
                break
        self.skip_whitespace()
        end = self.reader.tell()
        node = HeaderNode(start, end)
        self.append_node(node)

    def skip_line(self):
        while True:
            ch = self.reader.read()
            if ch == '' or ch == '\n':
                break

    def skip_delimiter(self):
        if self.reader.peek() == self.TOKEN_DELIMITER:
            self.reader.read()

    def skip_token(self, token):
        self.reader.read(len(token))

    def skip_whitespace_line(self):
        while True:
            ch = self.reader.peek()
            if ch == '':
                break
            if ch in {"\n", "\r", "\t", " "}:
                self.reader.read()
                if ch == '\n':
                    break
            else:
                break

    def skip_whitespace_inline(self):
        while True:
            ch = self.reader.peek()
            if ch in {"\r", "\t", " "}:
                self.reader.read()
            else:
                break

    def skip_whitespace(self):
        while True:
            ch = self.reader.peek()
            if ch in {"\n", "\r", "\t", " "}:
                self.reader.read()
            else:
                break

    def skip_quote(self):
        while True:
            ch = self.reader.read()
            if ch == '':
                raise TokenError("unexpected end")
            elif ch == '\\':
                self.reader.read()
            elif ch == '"':
                break
            else:
                continue

    def skip_brace(self):
        count = 1
        while True:
            if count == 0:
                break
            ch = self.reader.read()
            if ch == '':
                raise TokenError("unexpected end")
            elif ch == '"':
                self.skip_quote()
            elif ch == '}':
                count -= 1
            elif ch == '{':
                count += 1
            else:
                continue

    def parse_comment(self):
        self.reader.read(len(self.TOKEN_COMMENT))
        self.skip_line()

    def parse_var_name(self):
        name = ''
        while True:
            ch = self.reader.peek()
            if ch == '':
                return name
            cho = ord(ch)
            if (48 <= cho <= 57) or (65 <= cho <= 122):
                self.reader.read()
                name = f'{name}{ch}'
            elif ch in {"\n", "\r", "\t", " ", self.TOKEN_DELIMITER}:
                return name
            else:
                raise TokenError(f"variable name error, got: {ch}")

    def parse_local(self):
        start = self.reader.tell()
        self.skip_token(self.TOKEN_LOCAL)
        name = self.parse_var_name()
        self.skip_whitespace()
        buffered = self.reader.peek_all()
        if buffered.startswith(self.TOKEN_FUNC):
            self.parse_func(name, start)
        else:
            self.parse_var(name, start)

    def parse_global(self):
        start = self.reader.tell()
        self.skip_token(self.TOKEN_GLOBAL)
        name = self.parse_var_name()
        self.skip_whitespace()
        buffered = self.reader.peek_all()
        if buffered.startswith(self.TOKEN_FUNC):
            self.parse_func(name, start, True)
        else:
            self.parse_var(name, start, True)

    def parse_cmd(self):
        s = ':'
        start = self.reader.tell()
        self.skip_token(self.TOKEN_CMD)
        while True:
            ch = self.reader.read()
            s = f'{s}{ch}'
            if ch in {self.TOKEN_DELIMITER, '\n'}:
                break
        end = self.reader.tell()
        node = CMDNode(start, end, True, s)
        self.append_node(node)

    def parse_func(self, name, start, is_global=False):
        """parse_func
        :local func do={};
        """
        self.skip_token(self.TOKEN_FUNC)
        self.skip_brace()
        self.skip_delimiter()
        self.skip_whitespace_line()
        end = self.reader.tell()
        node = FuncNode(name, start, end, is_global, "TODO: ")
        self.append_node(node)

    def parse_var(self, name, start, is_global=False):
        """parse_var
        :local var {};
        """
        result = self.parse_var_switch()
        self.skip_delimiter()
        self.skip_whitespace_line()
        end = self.reader.tell()
        node = VarNode(name, start, end, is_global, result)
        self.append_node(node)

    def parse_var_switch(self):
        buffered = self.reader.peek_all()
        ch = buffered[0]
        if '0' <= ch <= '9':
            res = self.parse_var_num()
        elif buffered.startswith(self.TOKEN_VAR_ARRAY):
            res = self.parse_var_array()
        elif buffered.startswith("\""):
            res = self.parse_var_str()
        elif buffered.startswith(self.TOKEN_VAR_TRUE):
            res = self.parse_var_true()
        elif buffered.startswith(self.TOKEN_VAR_FALSE):
            res = self.parse_var_false()
        elif buffered.startswith(self.TOKEN_VAR_QUOTE):
            res = self.parse_var_quote()
        elif buffered.startswith(self.TOKEN_VAR_CMD):
            res = self.parse_var_cmd()
        elif buffered.startswith(self.TOKEN_VAR_BRACKET):
            res = self.parse_var_bracket()
        elif buffered.startswith(self.TOKEN_DELIMITER):
            res = ''
        else:
            import ipdb; ipdb.set_trace()
            res = self.parse_var_ambiguous()
        return res

    def parse_var_true(self):
        self.skip_token(self.TOKEN_VAR_TRUE)
        return True

    def parse_var_false(self):
        self.skip_token(self.TOKEN_VAR_FALSE)
        return False

    def parse_var_cmd(self):
        s = '['
        count = 1
        self.skip_token(self.TOKEN_VAR_CMD)
        while True:
            ch = self.reader.read()
            s = f'{s}{ch}'
            if ch == "[":
                count += 1
            elif ch == ']':
                count -= 1
            if count == 0:
                return s

    def parse_var_ambiguous(self, ):
        """TODO:"""
        pos = self.reader.tell()
        buffered = self.reader.peek_all()
        raise NotImplementedError(f"pos: {pos}, buffer: {buffered}")

    def parse_var_num(self):
        v = ''
        while True:
            ch = self.reader.peek()
            if '0' <= ch <= '9':
                v = f'{v}{ch}'
                self.reader.read()
            elif ch in {self.TOKEN_DELIMITER, self.TOKEN_VAR_ARRAY_END}:
                return int(v)
            elif ch in {'\n', '\r'}:
                return int(v)
            else:
                pos = self.reader.tell()
                buffered = self.reader.peek_all()
                raise NotImplementedError(f"pos: {pos}, buffer: {buffered}")

    def parse_var_str(self):
        s = ''
        # skip beginning double quote
        self.reader.read()
        # parse
        while True:
            ch = self.reader.peek()
            if ch == "\\":
                before_escape = self.parse_var_str_escaped()
                s = f'{s}{before_escape}'
            elif ch == '"':
                self.reader.read()
                return s
            else:
                self.reader.read()
                s = f'{s}{ch}'

    def parse_var_str_escaped(self):
        # skip beginning backslash
        s = self.reader.read()
        # parse
        while True:
            chs = self.reader.peek(2)
            if chs[0] in self.TOKEN_VAR_STR_ESCAPE_MAP:
                self.reader.read()
                return f'{s}{chs[0]}'
            else:
                # hex value
                int(f'0x{chs}', 16)
                self.reader.read(2)
                return f'{s}{chs}'

    def parse_var_quote(self):
        self.skip_token(self.TOKEN_VAR_QUOTE)
        name = self.parse_var_name()
        node = self._nodes_mapping.get(name)
        if node is None:
            import ipdb; ipdb.set_trace()
            raise KeyError(f"Quoted variable: {name} cannot found")
        return node.value

    def parse_var_bracket(self):
        s = '('
        count = 1
        self.skip_token(self.TOKEN_VAR_BRACKET)
        while True:
            ch = self.reader.read()
            s = f'{s}{ch}'
            if ch == self.TOKEN_VAR_BRACKET:
                count += 1
            elif ch == self.TOKEN_VAR_BRACKET_END:
                count -= 1
            if count == 0:
                return s

    def parse_var_array(self):
        result = []
        is_dict = None
        self.reader.read(len(self.TOKEN_VAR_ARRAY))
        while True:
            self.skip_whitespace()
            # break
            ch = self.reader.peek()
            if ch == self.TOKEN_VAR_ARRAY_END:
                self.reader.read()
                break
            # get k or v
            k = self.parse_var_switch()
            ch = self.reader.peek()
            if ch == "=":
                self.reader.read()
                if is_dict is None:
                    is_dict = True
                if is_dict is False:
                    raise TokenError("ambiguous array not support")
                v = self.parse_var_switch()
                result.append((k, v))
            else:
                if is_dict is None:
                    is_dict = False
                if is_dict is True:
                    raise TokenError("ambiguous array not support")
                result.append(k)
            # delimiter after item
            ch = self.reader.peek()
            if ch == self.TOKEN_DELIMITER:
                self.reader.read()
            elif ch == self.TOKEN_VAR_ARRAY_END:
                continue
            else:
                import ipdb; ipdb.set_trace()
                raise TokenError(f"expected delimiter, {ch}")
        # make result
        if is_dict:
            return dict(result)
        return result

    def parse_return(self):
        start = self.reader.tell()
        self.skip_token(self.TOKEN_RETURN)
        self.skip_whitespace_inline()
        result = self.parse_var_switch()
        self.skip_delimiter()
        self.skip_whitespace_line()
        end = self.reader.tell()
        node = ReturnNode(start, end, result)
        self.append_node(node)

    def get_return(self):
        node = self._nodes_mapping['return']
        return node

    def get_metainfo(self):
        if 'metaInfo' not in self._nodes_mapping:
            raise ValueError(f"metaInfo not found in package {self.name}")
        node = self._nodes_mapping['metaInfo']
        return node

    def get_global_functions(self):
        result = []
        for node in self._nodes:
            if isinstance(node, FuncNode):
                if node.is_global:
                    result.append(node)
        return result

    def get_global_variables(self):
        result = []
        for node in self._nodes:
            if isinstance(node, VarNode):
                if node.is_global:
                    result.append(node)
        return result

    def get_global_commands(self):
        result = []
        for node in self._nodes:
            if isinstance(node, CMDNode):
                if node.is_global:
                    result.append(node)
        return result

    def get_header(self):
        node = self._nodes_mapping['header']
        return node
