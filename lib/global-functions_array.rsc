#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.array
# ===================================================================
# ALL global functions follows upper camel case.
# Global functions are designed to perform array related operation.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="global-functions.array";
    "version"="0.5.1";
    "description"="Global functions are designed to perform array related operation.";
    "global"=true;
    "global-functions"={
        "Append";
        "Prepend";
        "Insert";
        "Extend";
        "Reverse";
        "GetKeys";
        "IsSubset";
        "IsSuperset";
    };
};


# $Append
# Return a new array by appending a variable to a numeric key array.
# args: <array>                 source array
# args: <var>                   var to append
# return: <array>               new array
:global Append do={
    :local a ($1, 0);
    :set ($a->[:len $1]) $2;
    :return $a;
}


# $Prepend
# Return a new array by prepending a variable to a numeric key array.
# args: <array>                 source array
# args: <var>                   var to prepend
# return: <array>               new array
:global Prepend do={
    :local a (0, $1);
    :set ($a->0) $2;
    :return $a;
}


# $Insert
# Return a new array by inserting a variable to a numeric key array at a specific index.
# args: <array>                 source array
# args: <var>                   var to insert
# args: <num>                   insert position
# return: <array>               new array
:global Insert do={
    # global declare
    :global NewArray;
    # local
    :local pre [$NewArray ];
    :local post [$NewArray ];
    :if ($3 > 0) do={
        :set pre [:pick $1 0 $3];
    }
    :if ($3 < [:len $1]) do={
        :set post [:pick $1 $3 [:len $1]];
    }
    :local a ($pre, 0, $post);
    :set ($a->[:tonum $3]) $2;
    :return $a;
}


# $Extend
# Return a new array by extending a numeric key array with another one at a specific index.
# args: <array>                 source array
# args: <array>                 array of var to extend at position
# args: <num>                   extend position
# return: <array>               new array
:global Extend do={
    # global declare
    :global NewArray;
    :global TypeofNum;
    :global ReadOption;
    # local
    :local pos [$ReadOption $3 $TypeofNum [:len $1]];
    :local pre [$NewArray ];
    :local post [$NewArray ];
    :if ($pos > 0) do={
        :set pre [:pick $1 0 $pos];
    }
    :if ($pos < [:len $1]) do={
        :set post [:pick $1 $pos [:len $1]];
    }
    :local a ($pre, $2, $post);
    :return $a;
}


# $Reverse
# Return a new reversed array.
# args: <array>                 target array
# return: <array>               new array
:global Reverse do={
    # global declare
    :global NewArray;
    # local
    :local result [$NewArray ];
    :for i from=([:len $1] - 1) to=0 step=-1 do={
        :set ($result->[:len $result]) ($1->$i);
    }
    :return $result;
}


# $GetKeys
# Return a new numeric key array by extracting the keys of an arbitrary array.
# args: <array>                 target array
# return: <array>               new array
:global GetKeys do={
    # global declare
    :global NewArray;
    # local
    :local keys [$NewArray ];
    :foreach k,v in $1 do={
        :set ($keys->[:len $keys]) $k;
    }
    :return $keys;
}


# $IsSubset
# Return if a numeric key array A is subset of another numeric key array B.
# args: <array>                 array A
# args: <array>                 array B
# return: <bool>                flag
:global IsSubset do={
    # global declare
    :global IsNil;
    :global NewArray;
    # local
    :if ([:len $1] > 0 and [:len $2] = 0) do={
        :return false;
    }
    :local m [$NewArray ];
    :foreach v in $2 do={
        :set ($m->$v) true;
    }
    :foreach v in $1 do={
        :if ([$IsNil ($m->$v)]) do={
            :return false;
        }
    }
    :return true;
}


# $IsSuperset
# Return if a numeric key array A is superset of another numeric key array B.
# args: <array>                 array A
# args: <array>                 array B
# return: <bool>                flag
:global IsSuperset do={
    # global declare
    :global IsNil;
    :global NewArray;
    # local
    :if ([:len $2] > 0 and [:len $1] = 0) do={
        :return false;
    }
    :local m [$NewArray ];
    :foreach v in $1 do={
        :set ($m->$v) true;
    }
    :foreach v in $2 do={
        :if ([$IsNil ($m->$v)]) do={
            :return false;
        }
    }
    :return true;
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
