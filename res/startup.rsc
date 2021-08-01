:local nameList {
    "global-variables";
    "global-functions";
    "global-functions_package";
    "global-helpers";
}

:foreach name in $nameList do={
    :local cmdStr "/system script run [/system script find name=\"$name\"];";
    :local cmdFunc [:parse $cmdStr];
    [$cmdFunc ];
}
