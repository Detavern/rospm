# loads

## common
{
    :local s "Hello {{ name }}!";
    :local v {"name"="Alice"};
    $Print [[$GetFunc "tool.template.render"] Template=$s Variables=$v];
}

## escaped
{
    :local s "Hello {{ name }}! {{ \"{{\" }} foo bar";
    :local v {"name"="Alice"};
    $Print [[$GetFunc "tool.template.render"] Template=$s Variables=$v];
}

## no key
{
    :local s "Hello {{ name }}! {{ \"{{\" }} foo bar";
    :local v {"foo"="Alice"};
    $Print [[$GetFunc "tool.template.render"] Template=$s Variables=$v];
}

## unicode 3B: chinese character, 你好
{
    :local s "{\"unicode\": \"\\u4f60\\u597d\"}";
    :local array [[$GetFunc "tool.json.loads"] Str=$s];
    $Print [:len ($array->"unicode")];
    /file/print file=myFile;
    /file/set "myFile.txt" content=($array->"unicode");
}

## unicode 4B: surrogate pair, U+1F600 😀
{
    :local s "{\"surrogate\": \"\\ud83d\\ude00\"}";
    :local array [[$GetFunc "tool.json.loads"] Str=$s];
    $Print [:len ($array->"surrogate")];
    /file/print file=myFile;
    /file/set "myFile.txt" content=($array->"surrogate");
}
