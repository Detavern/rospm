import io


class StreamReader:
    BUFFERING = 512

    def __init__(self, stream: io.BufferedReader) -> None:
        self._stream = stream

    @classmethod
    def from_file(cls, path):
        f = open(path, 'rb', buffering=cls.BUFFERING)
        return cls(f)

    @property
    def stream(self):
        return self._stream

    def tell(self) -> int:
        return self._stream.tell()

    def peek(self, num=1):
        buffered = self.stream.peek().decode()
        if buffered:
            return buffered[0:num]
        return ""

    def peek_all(self):
        buffered = self.stream.peek().decode()
        if len(buffered) < 100:
            pos = self.stream.tell()
            self.stream.read(self.BUFFERING)
            self.stream.seek(pos)
        return buffered

    def read(self, num=1):
        return self.stream.read(num).decode()
