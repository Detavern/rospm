import os

from .stream import StreamReader
from .utils import TMPL_ENV


class ScriptQuoteGenerator:
    STR_ESCAPE_MAP = {
        '"': '\\"',
        '$': '\\$',
        '\\': '\\\\',
    }

    def __init__(self, reader: StreamReader) -> None:
        self.reader = reader
        self._lines = []

    @classmethod
    def from_file(cls, path):
        inst = cls(StreamReader.from_file(path))
        inst()
        return inst

    def to_file(self, path):
        snip = self.generate_multiple_line('\r\n')
        with open(path, 'w') as f:
            f.write(snip)

    def to_importable_file(self, path: os.PathLike, name: str):
        tmpl = TMPL_ENV.get_template("importable.rsc.j2")
        snip = self.generate_multiple_line('\r\n')
        text = tmpl.render(
            package_name=name,
            script_name=name.replace('.', '_'),
            source=snip,
        )
        with open(path, 'w') as f:
            f.write(text)

    def __call__(self):
        # peek
        self.reader.peek()
        # parse others
        while True:
            ch = self.reader.peek()
            if not ch:
                break
            line = self.parse_line()
            self._lines.append(line)

    def parse_heading_space(self):
        c = 0
        while self.reader.peek() == ' ':
            self.reader.read()
            c += 1
        return '\\_' * c

    def parse_line(self):
        v = self.parse_heading_space()
        while True:
            ch = self.reader.peek()
            chs = self.reader.peek(2)
            if not ch:
                break
            elif ch == '\n':
                self.reader.read()
                break
            elif chs == '\r\n':
                self.reader.read(2)
                break
            else:
                ch = self.escape_char(ch)
                v = f'{v}{ch}'
                self.reader.read()
        return v

    def escape_char(self, ch):
        if ch in self.STR_ESCAPE_MAP:
            ch = self.STR_ESCAPE_MAP[ch]
        return ch

    def generate_multiple_line(self, newline):
        snip = f'\\r\\n\\{newline}'.join(self._lines)
        return snip
