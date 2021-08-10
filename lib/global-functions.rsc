# Global Functions
# =========================================================
# ALL global functions follows upper camel case.
#
# USE as your wish

:local metaInfo {
    "name"="global-functions";
    "version"="0.0.1";
    "description"="global function package";
    "global"=true;
};

# $IsNil
# validate if the variable is nil.
# Some example of nil situation:
# {
#    :local v;
#    :set v [:find "" "" 1];
#    :put ([$IsNil $1]);
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
#    :local v;
#    :put [$IsNothing $1];
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


# $Append
# Append variable for array without keys
# source array will not be changed
# args: <array>                 target array
# args: <var>                   var to append
# return: <array>               new array
:global Append do={
    :local a ($1, 0);
    :set ($a->[:len $1]) $2;
    :return $a;
}


# $Prepend
# Prepend variable for array without keys
# source array will not be changed
# args: <array>                 target array
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
# args: <array>                 target array
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
# args: <array>                 target array
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


# $Input
# get value from intraction
# args: <str>                   info
# return: <var>                 value
:global Input do={
    :terminal style escaped;
    :put $1; 
    :return;
}


# $InputV
# get value from intraction and recover its type and value
# args: <str>                   info
# args: <str>                   default value
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


# $Replace
# args: <str>                   string
# args: <str>                   old
# args: <str>                   new
# return: <str>                 string replaced
:global Replace do={
    # global declare
    :global IsNil;
    # local
    :local string $1;
    :local old $2;
    :local new $3;

    :local result "";
    :local flag true;
    :local cursor -1;
    :local pos -1;

    :while ($flag) do={
        # find first/next sub string
        :set pos [:find $string $old $cursor];
        :if ([$IsNil $pos]) do={
            :set flag false;
        } else {
            # pick pre string
            :local pre [:pick $string ($cursor + 1) $pos];
            # set new cursor
            :set cursor ($pos + [:len $old] - 1);
            # concat
            :set result ($result . $pre . $new);
        };
    };
    # concat post string
    :local post [:pick $string ($cursor + 1) [:len $string]];
    :set result ($result . $post);
    :return $result;
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


# $Split
# args: <str>                   target string
# args: <str>                   sub string
# args: <num>                   split count
# return: <array>               array
:global Split do={
    # global declare
    :global NewArray;
    :global IsNothing;
    :global IsNil;
    # local
    :local string $1;
    :local sub $2;
    :local maxCount $3;
    :if ([$IsNothing $maxCount]) do={
        set maxCount -1;
    };

    :local result [$NewArray];
    :local flag true;
    :local cursor -1;
    :local pos -1;
    :local count 0;

    :while ($flag) do={
        # find first/next sub string
        :set pos [:find $string $sub $cursor];
        :if ([$IsNil $pos] or ($count = $maxCount)) do={
            :set flag false;
        } else {
            :set count ($count + 1); 
            # pick pre string
            :local pre [:pick $string ($cursor + 1) $pos];
            :if ([$IsNil $pre]) do={
                :set pre "";
            }
            # set new cursor
            :set cursor ($pos + [:len $sub] - 1);
            # append
            :set result ($result , $pre);
        };
    };
    # append post string
    :local post [:pick $string ($cursor + 1) [:len $string]];
    # if $string endding with the $sub, append an empty string to the result 
    :if ([$IsNil $post]) do={
        :set post "";
    }
    :set result ($result , $post);
    :return $result;
}


# $RSplit
# args: <str>                   target string
# args: <str>                   sub string
# args: <num>                   split count
# return: <array>               array
:global RSplit do={
    # global declare
    :global NewArray;
    :global IsNothing;
    :global IsNil;
    :global Reverse;
    # local
    :local string $1;
    :local sub $2;
    :local maxCount $3;
    :if ([$IsNothing $maxCount]) do={
        set maxCount -1;
    };

    :local result [$NewArray];
    :local flag true;
    :local pos -1;
    :local count 0;
    :local lenString [:len $string];
    :local lenSub [:len $sub];
    :local cursor [:len $sub];
    :local cursorR $lenString;

    :while ($flag) do={
        # find first/next sub string
        # a->b->c->d
        :set pos [:find $string $sub ($lenString - $cursor - 1)];
        :if (($cursor > $lenString) or ($count = $maxCount)) do={
            :set flag false;
        } else {
            # if nil or same then move cursor left
            :if ([$IsNil $pos] or ($pos = $cursorR)) do={
                :set cursor ($cursor + 1);
            } else {
                :set count ($count + 1); 
                # pick post string
                :local post [:pick $string ($pos + $lenSub) $cursorR];
                # # if $string starting with the $sub, append an empty string to the result 
                :if ([$IsNil $post]) do={
                    :set post "";
                }
                # set new cursor & cursorR
                :set cursorR $pos;
                :set cursor ($cursor + $lenSub);
                # append
                :set result ($result , $post);
            }
        };
    };
    # append pre string
    :local pre [:pick $string 0 $cursorR];
    # if $string starting with the $sub, append an empty string to the result 
    :if ([$IsNil $pre]) do={
        :set pre "";
    }
    :set result ($result , $pre);
    # reverse array
    :set result [$Reverse $result];
    :return $result;
}


# $StartsWith
# args: <str>                   target string
# args: <str>                   sub string
# return: <bool>                true or not
:global StartsWith do={
    :local string $1;
    :local sub $2;
    # pick
    if ([:pick $string 0 [:len $sub]] = $sub) do={
        return true;
    } else {
        return false;
    }
}


# $EndsWith
# args: <str>                   target string
# args: <str>                   sub string
# return: <bool>                true or not
:global EndsWith do={
    :local string $1;
    :local sub $2;
    # pick
    if ([:pick $string ([:len $string] - [:len $sub]) [:len $string]] = $sub) do={
        return true;
    } else {
        return false;
    }
}


# $Strip
# args: <str>                   target string
# args: <array>                 array of characters to be removed
# opt kwargs: Mode=<str>        mode: b(both,default), l(left), r(right)
# return: <str>                 stripped string
:global Strip do={
    # global declare
    :global TypeofArray;
    :global TypeofStr;
    :global ReadOption;
    :global InValues;
    # local
    :local pMode [$ReadOption $Mode $TypeofStr "b"];
    :local defaultCL {("\r"); ("\n"); ("\t"); " "};
    :local charList [$ReadOption $2 $TypeofArray $defaultCL];
    :local string $1;
    :local flag true;
    :local posL 0;
    :local posM [:len $string];
    :local posR $posM ;
    # left side
    :if (($pMode = "b") or ($pMode = "l")) do={
        :set flag true;
        :while ($flag) do={
            :if ($posL < $posM) do={
                :local ch [:pick $string $posL ($posL + 1)];
                :if ([$InValues $ch $charList]) do={
                    :set posL ($posL + 1);
                } else {
                    :set flag false;
                }
            } else {
                :return "";
            }
        }
    }
    # right side
    :if (($pMode = "b") or ($pMode = "r")) do={
        :set flag true;
        :while ($flag) do={
            :if ($posR > $posL) do={
                :local ch [:pick $string ($posR - 1) $posR];
                :if ([$InValues $ch $charList]) do={
                    :set posR ($posR - 1);
                } else {
                    :set flag false;
                }
            } else {
                :return "";
            }
        }
    }
    # make new string
    :local result [:pick $string $posL $posR];
    :return $result;
}


# $Join
# args: <str>                   separator
# args: <array>                 array of concatenation
# return: <str>                 result
:global Join do={
    # global declare
    :local result "";
    :local sl ([:len $2]-1);
    :foreach k,v in $2 do={
        :if ($k < $sl) do={
            :set result ($result . $v . $1);
        } else {
            :set result ($result . $v);
        }
    }
    :return $result;
}


# :put [$SimpleDump <var> ]
:global SimpleDump do={
    :return ([:typeof $1] . "|" . [:tostr $1]);
}

# :put [$SimpleLoad <str> ]
:global SimpleLoad do={
    # global declare
    :global Nil;
    :global IsStr;
    :global TypeofStr;
    :global TypeofNum;
    :global TypeofBool;
    :global TypeofID;
    :global TypeofTime;
    :global TypeofIP;
    :global TypeofIPPrefix;
    :global TypeofIPv6;
    :global TypeofIPv6Prefix;
    :global TypeofNil;
    :global TypeofArray;
    :global Split;
    # local
    :if (![$IsStr $1]) do={
        :error "Global.SimpleLoad: type error, need string";
    }
    :local array [$Split $1 "|" 1];
    # type match
    :local typeName ($array->0);
    :if ($typeName = $TypeofStr) do={
        :return ($array->1);
    }
    :if ($typeName = $TypeofNum) do={
        :return [:tonum ($array->1)];
    }
    :if ($typeName = $TypeofBool) do={
        :return [:tobool ($array->1)];
    }
    :if ($typeName = $TypeofID) do={
        :return [:toid ($array->1)];
    }
    :if ($typeName = $TypeofTime) do={
        :return [:totime ($array->1)];
    }
    :if ($typeName = $TypeofIP) do={
        :return [:toip ($array->1)];
    }
    :if ($typeName = $TypeofIPPrefix) do={
        :return [:toip ($array->1)];
    }
    :if ($typeName = $TypeofIPv6) do={
        :return [:toip6 ($array->1)];
    }
    :if ($typeName = $TypeofIPv6Prefix) do={
        :return [:toip6 ($array->1)];
    }
    :if ($typeName = $TypeofNil) do={
        :return $Nil;
    }
    :if ($typeName = $TypeofArray) do={
        :return [:toarray ($array->1)];
    }
    # unknown type
    :error "Global.SimpleLoad: unknown type $typeName";
}


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
