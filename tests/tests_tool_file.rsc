# file creation

## create file
{
    :local cost [[$GetFunc "tool.file.create"] Name="t.txt"];
    :put "create a file took $cost ms";
}

## create folder
{
    [[$GetFunc "tool.file.createDir"] Name="test/test_2"]
}

## file name regex check
{
    :local files {
        # positive
        "test.rsc"; "testdwa"; "test.abc.backup"; "_dwada.backup";
        "test test.rsc"; "a b c.rsc"; "a b  c.rsc";
        # negative
        "\$a b  c.rsc";
    };
    :local isFile false;
    :foreach f in $files do={
        # must follow the order
        :set isFile ($f ~ "^([A-Za-z0-9_-]|\_)+(\\.[A-Za-z0-9]+)*\$");
        :put ("$f    $isFile");
    }
}

## find file

{
    :local nameList [[$GetFunc "tool.file.find"] Name="rspm-installer-develop.rsc"];
    :put $nameList;
}
