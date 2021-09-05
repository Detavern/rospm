# loads

## common
{
    :local s "{\"k1\": \"hello\",\"k2\": \"world\"}";
    $Print [[$GetFunc "tool.json.loads"] Str=$s];
}

## string escaped
{
    :local s "{\"escaped1\": \"\\n\\/\\t\",\"escaped2\": \"\\n\\t/\"}";
    $Print [:len ([[$GetFunc "tool.json.loads"] Str=$s]->"escaped1")];
    $Print [:len ([[$GetFunc "tool.json.loads"] Str=$s]->"escaped2")];
}

## unicode 3B: chinese character, 你好
{
    :local s "{\"unicode\": \"\\u4f60\\u597d\"}";
    :local array [[$GetFunc "tool.json.loads"] Str=$s];
    $Print [:len ($array->"unicode")];
    /file print file=myFile;
    /file set "myFile.txt" content=($array->"unicode");
}

## unicode 4B: surrogate pair, U+1F600 😀
{
    :local s "{\"surrogate\": \"\\ud83d\\ude00\"}";
    :local array [[$GetFunc "tool.json.loads"] Str=$s];
    $Print [:len ($array->"surrogate")];
    /file print file=myFile;
    /file set "myFile.txt" content=($array->"surrogate");
}

## benchmark test
## chr 6.48, 1 cpu 2.5GHz

### 4000B json file, 2 indent, Original Winand / mikrotik-json-parser
### result: 0-1 sec

### 4000B json file, no indent, Original Winand / mikrotik-json-parser
### result: 0-1 sec
{
    :local st [$GetCurrentDatetime ];
    :local s [/file get number=[/file find name="4k-sample-noindent.json"] contents];
    :local array [$JSONLoads $s];
    :local et [$GetCurrentDatetime ];
    :put $st;
    :put $et;
}

### MAX variable length limit is 4096

### 4000B json file, 2 indent, no package cache
### result: 6-7 sec

### 4000B json file, no indent, no package cache
### result: 10-11 sec

{
    :local st [$GetCurrentDatetime ];
    :local s [/file get number=[/file find name="4k-sample.json"] contents];
    :local array [[$GetFunc "tool.json.loads"] Str=$s];
    :local et [$GetCurrentDatetime ];
    :put $st;
    :put $et;
}

### 4000B json file, 2 indent, LRU function cache enabled
### result: 0-1 sec

### 4000B json file, no indent, LRU function cache enabled
### result: 0-1 sec

### it seems split function in GetFunc cost greatly when invoking a recusive function
{
    :local st [$GetCurrentDatetime ];
    :local s [/file get number=[/file find name="4k-sample-noindent.json"] contents];
    :local array [[$GetFunc "tool.json.loads"] Str=$s];
    :local et [$GetCurrentDatetime ];
    :put $st;
    :put $et;
}
