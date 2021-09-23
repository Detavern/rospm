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