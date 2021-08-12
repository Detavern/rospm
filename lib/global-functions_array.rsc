# Global Functions | Array
# =========================================================
# ALL global functions follows upper camel case.
# Global Package for array related operation.
#
# USE as your wish

:local metaInfo {
    "name"="global-functions.array";
    "version"="0.1.0";
    "description"="global functions for array related operation";
    "global"=true;
};



# $Append
# Append variable for array without keys(num key)
# source array will not be changed
# args: <array>                 source array
# args: <var>                   var to append
# return: <array>               new array
:global Append do={
    :local a ($1, 0);
    :set ($a->[:len $1]) $2;
    :return $a;
}


# $Appends
# Append variable for array without keys(num key)
# source array will change
# args: <array>                 source array
# args: <var>                   var to append
# return: <array>               changed source array
:global Appends do={
    :local a $1;
    :set ($a->[:len $a]) $2;
    :return $a;
}


# $Prepend
# Prepend variable for array without keys
# source array will not be changed
# args: <array>                 source array
# args: <var>                   var to prepend
# return: <array>               new array
:global Prepend do={
    :local a (0, $1);
    :set ($a->0) $2;
    :return $a;
}


# $Insert
# Insert variable for array without keys
# source array will not be changed
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
# Extend array without keys
# source array will not change
# args: <array>                 source array
# args: <array>                 array of var to extend at position
# args: <num>                   extend position
# return: <array>               new array
:global Extend do={
    # global declare
    :global NewArray;
    :global TypeofNum;
    :global ReadOption;
    :global Print;
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
# reverse an array without keys
# args: <array>                 target array
# return: <str>                 array
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


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
