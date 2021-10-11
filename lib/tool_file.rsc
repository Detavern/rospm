#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   tool.file
# ===================================================================
# ALL package level functions follows lower camel case.
# file utility
#
# Copyright (c) 2020-2021 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="tool.file";
    "version"="0.3.1";
    "description"="file utility";
};


# $create
# currently only support create *.txt file
# kwargs: Name=<str>                    file name
# return: <num>                         time cost
:local create do={
    #DEFINE global
    :global IsEmpty;
    :global IsStr;
    :global RSplit;
    # check
    :if (![$IsStr $Name]) do={
        :error "tool.file.create: require \$Name";
    }
    :if ($Name = "") do={
        :error "tool.file.create: empty \$Name";
    }
    :local splitted [$RSplit $Name "." 1];
    :local suffix [:pick $splitted ([:len $splitted] - 1)];
    :if ($suffix != "txt") do={
        :error "tool.file.create: only support create txt file currently.";
    }
    # local
    :local interval 200;
    :local timer 0;
    :local timerMax 5000;
    /file print file=$Name;
    :while ($timer < $timerMax) do={
        :delay ("$interval" . "ms");
        :set timer ($timer + $interval)
        :if (![$IsEmpty [/file find name=$Name]]) do={
            :return $timer;
        }
    }
    :error "tool.file.create: timeout";
}


# $createDir
# create directory via fetch http://127.0.0.1/favicon.png into file
# this function DOES NOT depends on whether /ip service www is enabled or not
# this function will not raise error when folder already exist
# kwargs: Name=<str>                    file name
:local createDir do={
    #DEFINE global
    :global IsEmpty;
    :global IsStr;
    # check
    :if (![$IsStr $Name]) do={
        :error "tool.file.createDir: require \$Name";
    }
    :if ($Name = "") do={
        :error "tool.file.createDir: empty \$Name";
    }
    # local
    :do {
        :local result [/tool fetch "http://127.0.0.1/favicon.png" dst-path="$Name/tmp" as-value];
    } on-error={}
    :local idList [/file find name="$Name/tmp"];
    :if (![$IsEmpty]) do={
        /file remove $idList;
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "create"=$create;
    "createDir"=$createDir;
}
:return $package;
