# Global Functions | Misc
# =========================================================
# ALL global functions follows upper camel case.
# Global Package for miscellaneous collection.
#
# USE as your wish

:local metaInfo {
    "name"="global-functions.misc";
    "version"="0.1.0";
    "description"="global functions for miscellaneous collection";
    "global"=true;
};


# $UniqueArray
# let an array to be a unique one by values
# args: <array>                 target array
# return: <array>               array
:global UniqueArray do={
    # global declare
    :global NewArray;
    :global SimpleDump;
    :global SimpleLoad;
    # local
    :local mapped [$NewArray ];
    :local result [$NewArray ];
    # dump value and put it into map
    :foreach v in $1 do={
        # :put $v;
        :local key [$SimpleDump $v];
        :set ($mapped->$key) 1;
    }
    # load dumpped value
    :foreach k,v in $mapped do={
        :set result ($result, [$SimpleLoad $k])
    }
    :return $result;
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
