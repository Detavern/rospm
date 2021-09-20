## encode
{
    :local s "\\u4f60\\u597d dsomebody\\nnew line";
    :local encoded [$EncodeUtf8 $s];
    $Print $encoded;
}

## utf8 to unicode code point, \u20ac, 8364
{
    :local s "\E2\82\AC";
    :local n [$Utf8ToUnicode $s];
    $Print $n;
}

## utf8 to unicode code point, \u10348, 66376
{
    :local s "\F0\90\8D\88";
    :local n [$Utf8ToUnicode $s];
    $Print $n;
    :local hex [$ToHex $n];
    $Print $hex;
    :local es [$Utf8ToUnicodeEscaped $s];
    $Print $es;
}