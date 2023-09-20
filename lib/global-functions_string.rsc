#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.string
# ===================================================================
# ALL global functions follows upper camel case.
# global functions for string related operation
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="global-functions.string";
    "version"="0.5.0";
    "description"="global functions for string related operation";
    "global"=true;
    "global-functions"={
        "Replace";
        "Split";
        "RSplit";
        "StartsWith";
        "EndsWith";
        "Strip";
        "Join";
        "SimpleDump";
        "SimpleLoad";
        "NumToHex";
        "HexToNum";
    };
};


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


# $Split
# args: <str>                   target string
# args: <str>                   sub string
# opt args: <num>               split count
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
# opt args: <num>               split count
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
# opt args: <str>               characters to be removed
# opt kwargs: Mode=<str>        mode: b(both,default), l(left), r(right)
# return: <str>                 stripped string
:global Strip do={
    # global declare
    :global TypeofStr;
    :global ReadOption;
    :global NewArray;
    :global InValues;
    # local
    :local pMode [$ReadOption $Mode $TypeofStr "b"];
    :local charStr [$ReadOption $2 $TypeofStr ("\r\n\t ")];
    :local string $1;
    :local flag true;
    :local posL 0;
    :local posM [:len $string];
    :local posR $posM;
    # charList
    :local charList [$NewArray ];
    :for cursor from=0 to=([:len $charStr] - 1) step=1 do={
        :local char [:pick $charStr $cursor ($cursor + 1)];
        :if (![$InValues $char $charList]) do={
            :set ($charList->[:len $charList]) $char;
        }
    }
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


# $NumToHex
# convert number to hex string
# args: <num>                   num
# return: <str>                 hex string (0x12abdc)
:global NumToHex do={
    # global
    :global Strip;
    # local
    :local v [:tonum $1];
    :local hex "";
    :local ch;
    :while ($v > 0) do={
        :set ch ($v & 0xFF);
        :set v ($v >> 8);
        :local h1 [:pick "0123456789abcdef" (($ch >> 4) & 0xF)];
        :local h2 [:pick "0123456789abcdef" ($ch & 0xF)];
        :set hex ("$h1$h2" . $hex);
    }
    # strip 0
    :set hex ("0x" . [$Strip $hex "0" Mode="l"]);
    :return $hex;
}


# $HexToNum
# convert hex string to number
# args: <str>                   hex string (0x12abdc)
# return: <num>                 number
:global HexToNum do={
    # local
    :local s [:tostr $1];
    :set s [:pick $s 2 [:len $s]];
    :local h "0123456789abcdef0123456789ABCDEF";
    :local c 1;
    :local v 0;
    :for i from=([:len $s] - 1) to=0 step=-1 do={
        :set v ($v + (([:find $h [:pick $s $i]] % 16) * $c));
        :set c ($c * 16);
    }
    :return $v;
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
