# Global Functions
# =========================================================
# ALL global functions follows upper camel case.
#
# USE as your wish

:local metaInfo {
    "name"="global-functions";
    "version"="0.1.1";
    "description"="global function package";
    "global"=true;
};

# $IsNil
# validate if the variable is nil.
# Some example of nil situation:
# {
#     :local v;
#     :set v [:find "" "" 1];
#     :put ([$IsNil $1]);
# }
# TODO: ADD MORE HERE
# args: <var>                   variable
:global IsNil do={
    :global TypeofNil;
    :if ([:typeof $1] = $TypeofNil) do={
        return true;
    } else {
        return false;
    }
}


# $IsNothing
# validate if the variable is nothing.
# Some example of nothing situation:
# {
#     :local v;
#     :put [$IsNothing $1];
# }
# {
#     :local a {"k"="v"};
#     :put [$IsNothing ($a->"notexist")];
# }
# TODO: ADD MORE HERE
# args: <var>                   variable
:global IsNothing do={
    :global TypeofNothing;
    :if ([:typeof $1] = $TypeofNothing) do={
        return true;
    } else {
        return false;
    }
}


# $IsNum
# validate the type of variable.
# args: <var>                   variable
:global IsNum do={
    :global TypeofNum;
    :if ([:typeof $1] = $TypeofNum) do={
        return true;
    } else {
        return false;
    }
}


# $IsStr
# validate the type of variable.
# args: <var>                   variable
:global IsStr do={
    :global TypeofStr;
    :if ([:typeof $1] = $TypeofStr) do={
        return true;
    } else {
        return false;
    }
}


# $IsBool
# validate the type of variable.
# args: <var>                   variable
:global IsBool do={
    :global TypeofBool;
    :if ([:typeof $1] = $TypeofBool) do={
        return true;
    } else {
        return false;
    }
}


# $IsTime
# validate the type of variable.
# args: <var>                   variable
:global IsTime do={
    :global TypeofTime;
    :if ([:typeof $1] = $TypeofTime) do={
        return true;
    } else {
        return false;
    }
}


# $IsArray
# validate the type of variable.
# args: <var>                   variable
:global IsArray do={
    :global TypeofArray;
    :if ([:typeof $1] = $TypeofArray) do={
        return true;
    } else {
        return false;
    }
}


# $IsIP
# validate the type of variable.
# args: <var>                   variable
:global IsIP do={
    :global TypeofIP;
    :if ([:typeof $1] = $TypeofIP) do={
        return true;
    } else {
        return false;
    }
}


# $IsIPv6
# validate the type of variable.
# args: <var>                   variable
:global IsIPv6 do={
    :global TypeofIPv6;
    :if ([:typeof $1] = $TypeofIPv6) do={
        return true;
    } else {
        return false;
    }
}


# $IsIPPrefix
# validate the type of variable.
# args: <var>                   variable
:global IsIPPrefix do={
    :global TypeofIPPrefix;
    :if ([:typeof $1] = $TypeofIPPrefix) do={
        return true;
    } else {
        return false;
    }
}


# $IsIPv6Prefix
# validate the type of variable.
# args: <var>                   variable
:global IsIPv6Prefix do={
    :global TypeofIPv6Prefix;
    :if ([:typeof $1] = $TypeofIPv6Prefix) do={
        return true;
    } else {
        return false;
    }
}


# $IsEmpty
# validate if an array is empty.
# args: <array>                 array
:global IsEmpty do={
    :global IsArray;
    :if ([$IsArray $1]) do={
        :if ([:len $1]=0) do={
            :return true;
        }
    }
    :return false;
}


# $NewArray
# get a new empty array.
# return: <array>               <empty array>
:global NewArray do={
    :return [:toarray ""]
}


# $Assert
# assert the condition, print error message if false.
# args: <bool>                  condition
# args: <str>                   error message
:global Assert do={
    :if ($1=false) do={
        :error "Assert error: $2";
    }
}


# $Print
# print the detail of the variable
# TODO: embbed array
# args: <var>                   variable
:global Print do={
    # global declare
    :global IsArray;
    :global IsEmpty;
    # put type first
    :put ("Type  : " . [:typeof $1]);
    :local vStr "Value : ";
    # unpack if array
    :if ([$IsArray $1]) do={
        :foreach k,v in $1 do={
            :put ("Key $k: " . [:tostr $v]);
        }
        :if ([$IsEmpty $1]) do={
            :put "Empty Array"
        }
    } else {
        :put ("Value : " . [:tostr $1]);
    }
}


# $PrintK
# print the keys of an array
# args: <array>                 array
:global PrintK do={
    # global declare
    :global IsArray;
    # check
    :if ([$IsArray $1]) do={
        :put ("Length: " . [:len $1]);
        :foreach k,v in $1 do={
            :put ("Key $k: ");
        }
        :if ([$IsEmpty $1]) do={
            :put "Empty Array"
        }
    } else {
        :error ("Global.PrintK: need an array")
    }
}


# $GetGlobal
# get global variable's value by its name
# args: <name>                  name
:global GetGlobal do={
    :local cmd ":global $1;:return \$$1";
    :local cmdFunc [:parse $cmd];
    :local gVar [$cmdFunc];
    :return $gVar;
}


# $ReadOption
# validate the type of input, could set default value
# args: <var>                   <value>
# args: <var>                   typeof <value>
# args: <var>                   default value of $1
# return: <var>                 <value or default>
:global ReadOption do={
    # global declare
    :global Nil;
    :global IsNothing;
    :global IsNil;
    :global IsStr;
    :global TypeRecovery;
    :global TypeofBool;
    :global TypeofNum;
    :global TypeofID;
    :global TypeofTime;
    :global TypeofIP;
    :global TypeofIPv6;
    :global TypeofArray;
    # local
    :local default;
    # check default value type match
    :if (![$IsNothing $3]) do={
        :if ([:typeof $3]=$2) do={
            :set default $3;
        } else {
            :if ([$IsStr $3]) do={
                :set default [$TypeRecovery $3];
                :if ([:typeof $default]!=$2) do={
                    :error "Global.ReadOption: type of \$default should match \$Typeof";
                }
            } else {
                :local hint ("<type>: " . [:typeof $3] . " <value>: $3");
                :error "Global.ReadOption: type of \$default should match \$Typeof, $hint";
            }
        }
    }
    # nothing, no default, return nil
    # nothing, has default, return default
    :if ([$IsNothing $1]) do={
        :if ([$IsNothing $default]) do={
            :return $Nil;
        } else {
            :return $default;
        }
    }
    :if ([$IsNil $1]) do={
        :error "Global.ReadOption: get nil value";
    }
    # type specific
    :if ($2 = $TypeofBool) do={
        :if ($1 = "false") do={
            :return false;
        };
        :if ($1 = "true") do={
            :return true;
        }
        :local b [:tobool $1];
        :if ([$IsNil $b]) do={
            :error "Global.ReadOption: target bool, get nil value";
        } else {
            :return $b;
        }
    }
    :if ($2 = $TypeofNum) do={
        :return [:tonum $1];
    }
    :if ($2 = $TypeofID) do={
        :return [:toid $1];
    }
    :if ($2 = $TypeofTime) do={
        :return [:totime $1];
    }
    :if ($2 = $TypeofIP) do={
        :return [:toip $1];
    }
    :if ($2 = $TypeofIPv6) do={
        :return [:toip6 $1];
    }
    :if ($2 = $TypeofArray) do={
        :if ([:typeof $1] != $TypeofArray) do={
            :error "Global.ReadOption: \$1 should be an array";
        }
    }
    # default return
    :return $1;
}


# $InKeys
# check if an element exists in the keys of an array
# args: <var>                   key to seach
# args: <array->var>            array to search in
# return: <bool>                in or not
:global InKeys do={
    :foreach k,v in $2 do={
        :if ($k=$1) do={
            :return true;
        }
    }
    :return false;
}


# $InKeys
# check if an element exists in the values of an array
# args: <var>                   value to seach
# args: <array->var>            array to search in
# return: <bool>                in or not
:global InValues do={
    :foreach k,v in $2 do={
        :if ($v=$1) do={
            :return true;
        }
    }
    :return false;
}


# $TypeRecovery
# recover type and value from a string
# args: <str>                   value to recover
# return: <var>                 recovered value
:global TypeRecovery do={
    :local value;
    :do {
        :local cmdStr "{:local rT do={:return \$1}; :local v $1; \$rT \$v;}";
        :local cmdFunc [:parse $cmdStr];
        :set value [$cmdFunc ];
    } on-error={
        :set value $1;
    }
    :return $value;
}


# $ByteToChar
# convert a single byte to character
# args: <num>                   num, 0x00 to 0xFF
# return: <str>                 character
:global ByteToChar do={
    :if ($1 > 255) do={
        :error "Global.ByteToChar: \$1 should smaller than 256"
    }
    :local h1 [:pick "0123456789ABCDEF" (($1 >> 4) & 0xF)];
    :local h2 [:pick "0123456789ABCDEF" ($1 & 0xF)];
    :return [[:parse "(\"\\$h1$h2\")"]];
}


# $Encode
# convert unicode code point into utf-8 character
# unicode: U+0000 - U+10FFFF
# start     end         byte count      byte 1
# U+0000    U+007F      1 char          0xxx xxxx
# U+0080    U+07FF      2 char          110x xxxx
# U+0800    U+FFFF      3 char          1110 xxxx
# U+10000   U+10FFFF    4 char          1111 0xxx
# args: <num>                   num, U+0000 to U+10FFFF
# return: <str>                 character
:global Encode do={
    # global
    :global TypeRecovery;
    :global ByteToChar;
    # check
    :local unicode [$TypeRecovery $1];
    :if (($1 > 0x10FFFF) or ($1 < 0)) do={
        :error "Global.Encode: not in range(0x0000 to 0x110000)";
    }
    :local byteNum;
    :local result "";
    # local
    :if ($1 < 0x80) do={
        :return [$ByteToChar $1];
    } else {
        :if ($1 < 0x800) do={
            :set byteNum 2;
        } else {
            :if ($1 < 0x10000) do={
                :set byteNum 3;
            } else {
                :set byteNum 4;
            }
        }
    }
    :for i from=2 to=$byteNum do={
        # pick last 6 bit and prepend 10 ahead, that make a byte 10xxxxxx(continuation byte)
        :set result ([$ByteToChar ($unicode & 0x3F | 0x80)] . $result)
        :set unicode ($unicode >> 6)
    }
    # make first byte
    :set result ([$ByteToChar (((0xFF00 >> $byteNum) & 0xFF) | $unicode)] . $result);
    :return $result;
}


# $Decode
# convert a utf-8 character back to unicode point
:global Decode do={
    # TODO: implement
}


# $Input
# get value from interaction
# args: <str>                   info
# return: <var>                 value
:global Input do={
    :terminal style escaped;
    :put $1; 
    :return;
}


# $InputV
# get value from interaction and recover its type and value
# args: <str>                   info
# opt args: <str>               answer
# return: <var>                 recovered value
:global InputV do={
    # global declare
    :global IsNothing;
    :global IsStr;
    :global Input;
    :global TypeRecovery;
    # local
    :if (![$IsStr $1]) do={
        :error "Global.InputV: first param should be str"
    }
    :if ([$IsNothing $2]) do={
        :local valueStr [$Input $1];
        :return [$TypeRecovery $valueStr];
    } else {
        :return [$TypeRecovery $2];
    }
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
