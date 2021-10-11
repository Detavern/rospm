#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   tool.json
# ===================================================================
# ALL package level functions follows lower camel case.
# json loads and dumps
#
# Copyright (c) 2020-2021 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
# For loading json string
# This parser can load validated json string into an array object with following limitations:
# - the variable length limitation is 4096, so your json string length should be less than 4096.
# - since there is only num type(int) in RouterOS, all float value will convert into string.
# - the maximun and minimun value of num type is -2^63 to 2^63-1, keep your json value in that range.
# - the order of json object will not preserve after conversion.
# - the parser can load validated json string DOES NOT mean the original json string is validated.
#   there is the situation that original json has format error but the parser could still parse it.
# You can check the test file `tests/tests_tool_json.rsc` for detail.
#
:local metaInfo {
    "name"="tool.json";
    "version"="0.3.0";
    "description"="json loads and dumps";
};


# $skipWhitespace
# kwargs: JSP=<array>                json parse array
:local skipWhitespace do={
    :while (($JSP->"pos") < ($JSP->"len") and ([:pick ($JSP->"text") ($JSP->"pos")] ~ "[ \r\n\t]")) do={
        :set ($JSP->"pos") (($JSP->"pos") + 1);
    }
}


# $parseObject
# kwargs: JSP=<array>                json parse array
:local parseObject do={
    #DEFINE global
    :global NewArray;
    :global GetFunc;
    # local
    :local jsp $JSP;
    :local flag true;
    :local ch;
    :local key;
    :local value;
    :local result [$NewArray ];
    # skip whitespace
    [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
    :while ($flag and ($jsp->"pos") < ($jsp->"len")) do={
        :set ch [:pick ($jsp->"text") ($jsp->"pos")];
        :if ($ch = "}") do={
            :set ($jsp->"pos") (($jsp->"pos") + 1);
            :set flag false;
        } else {
            :if ($ch != "\"") do={
                :local pos ($jsp->"pos");
                :error "tool.json.parseObject: pos: $pos, expected \" after {"
            } else {
                # key
                :set ($jsp->"pos") (($jsp->"pos") + 1);
                :set key [[$GetFunc "tool.json.parseString"] JSP=$jsp];
                # delimiter between k,v
                [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
                :set ch [:pick ($jsp->"text") ($jsp->"pos")];
                :if ($ch != ":") do={
                    :local pos ($jsp->"pos");
                    :error "tool.json.parseObject: pos: $pos, expected delimiter : between k,v";
                } else {
                    :set ($jsp->"pos") (($jsp->"pos") + 1);
                    # value
                    :set value [[$GetFunc "tool.json.parseSwitch"] JSP=$jsp];
                    :set ($result->$key) $value;
                    # delimiter after k,v
                    :set ch [:pick ($jsp->"text") ($jsp->"pos")];
                    :if ($ch = ",") do={
                        :set ($jsp->"pos") (($jsp->"pos") + 1);
                        [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
                    } else {
                        [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
                        :set ch [:pick ($jsp->"text") ($jsp->"pos")];
                        :if ($ch != "}") do={
                            :local pos ($jsp->"pos");
                            :error "tool.json.parseObject: pos: $pos, expected delimiter } after all k,v pair";
                        }
                    }
                }
            }
        }
    }
    :return $result;
}


# $parseArray
# kwargs: JSP=<array>                json parse array
:local parseArray do={
    #DEFINE global
    :global NewArray;
    :global GetFunc;
    # local
    :local jsp $JSP;
    :local flag true;
    :local ch;
    :local value;
    :local result [$NewArray ];
    # skip whitespace
    [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
    :while ($flag and ($jsp->"pos") < ($jsp->"len")) do={
        :set ch [:pick ($jsp->"text") ($jsp->"pos")];
        :if ($ch = "]") do={
            :set ($jsp->"pos") (($jsp->"pos") + 1);
            :set flag false;
        } else {
            :set value [[$GetFunc "tool.json.parseSwitch"] JSP=$jsp];
            :set ($result->[:len $result]) $value;
            :set ch [:pick ($jsp->"text") ($jsp->"pos")];
            :if ($ch = ",") do={
                :set ($jsp->"pos") (($jsp->"pos") + 1);
                [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
            } else {
                [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
                :set ch [:pick ($jsp->"text") ($jsp->"pos")];
                :if ($ch != "]") do={
                    :local pos ($jsp->"pos");
                    :error "tool.json.parseArray: pos: $pos, expected delimiter ] after all value";
                }
            }
        }
    }
    :return $result;
}


# $parseString
# kwargs: JSP=<array>                json parse array
:local parseString do={
    #DEFINE global
    :global UnicodeToUtf8;
    :global GetFunc;
    # local
    :local jsp $JSP;
    :local ch;
    :local nch;
    :local result "";
    :local flag true;
    :while ($flag and ($jsp->"pos") < ($jsp->"len")) do={
        :set ch [:pick ($jsp->"text") ($jsp->"pos")];
        :if ($ch = "\"") do={
            :set ($jsp->"pos") (($jsp->"pos") + 1);
            :set flag false;
        } else {
            :if ($ch = "\\") do={
                # char escape
                :local ch2 [:pick ($jsp->"text") (($jsp->"pos") + 1)];
                :if ($ch2 = "u") do={
                    # unicode escape
                    :local unicodeStr [:pick ($jsp->"text") (($jsp->"pos") + 2) (($jsp->"pos") + 6)];
                    :local unicode [:tonum "0x$unicodeStr"];
                    :if ($unicode >= 0xD800 and $utf <= 0xDFFF) do={
                        # unicode pair surrogate
                        # \uxxxx\uxxxx 12 chars
                        :local surrogateHigh (($unicode & 0x3FF) << 10);
                        :local surrogateLowStr [:pick ($jsp->"text") (($jsp->"pos") + 8) (($jsp->"pos") + 12)];
                        :local surrogateLow ([:tonum "0x$surrogateLowStr"] & 0x3FF);
                        :set unicode ($surrogateHigh | $surrogateLow | 0x10000);
                        :set ($jsp->"pos") (($jsp->"pos") + 12);
                    } else {
                        # basic multilingual plane
                        # \uxxxx 6 chars
                        :set ($jsp->"pos") (($jsp->"pos") + 6);
                    }
                    # convert code point to utf-8 str
                    :set nch [$UnicodeToUtf8 $unicode];
                } else {
                    # other escape
                    :if ($ch2 ~ "[\\bfnrt\"]") do={
                        :set nch [[:parse "(\"\\$ch2\")"]];
                        :set ($jsp->"pos") (($jsp->"pos") + 2);
                    } else {
                        :if ($ch2 = "/") do={
                            :set ($jsp->"pos") (($jsp->"pos") + 2);
                            :set nch $ch2;
                        } else {
                            :local pos ($jsp->"pos");
                            :error "tool.json.parseString: pos: $pos, expected token after \\";
                        }
                    }
                }
            } else {
                :set nch $ch;
                :set ($jsp->"pos") (($jsp->"pos") + 1);
            }
            :set result ($result . $nch)
        }
    }
    # skip whitespace
    :return $result;
}


# $parseNumber
# kwargs: JSP=<array>                json parse array
:local parseNumber do={
    #DEFINE global
    :global IsNum;
    :global GetFunc;
    # local
    :local jsp $JSP;
    :local flag true;
    :local ch;
    :local startPos ($jsp->"pos");
    :while ($flag and ($jsp->"pos") < ($jsp->"len")) do={
        :set ch [:pick ($jsp->"text") ($jsp->"pos")];
        :if ($ch ~ "[eE0-9.+-]") do={
            :set ($jsp->"pos") (($jsp->"pos") + 1);
        } else {
            :set flag false;
        }
    }
    # number
    :local numberStr [:pick ($jsp->"text") $startPos ($jsp->"pos")];
    :local number [:tonum $numberStr];
    :if ([$IsNum $number]) do={
        :return $number;
    } else {
        :return $numberStr;
    }
}


# $parseSwitch
# kwargs: JSP=<array>                json parse array
:local parseSwitch do={
    #DEFINE global
    :global Nil;
    :global IsStr;
    :global GetFunc;
    # local
    :local jsp $JSP;
    :local ch;
    :local flag true;
    # skip
    [[$GetFunc "tool.json.skipWhitespace"] JSP=$jsp];
    :set ch [:pick ($jsp->"text") ($jsp->"pos")];
    # switch token
    :if ($flag and $ch = "{") do={
        :set ($jsp->"pos") (($jsp->"pos") + 1);
        :set flag false;
        :return [[$GetFunc "tool.json.parseObject"] JSP=$jsp];
    }
    :if ($flag and $ch = "[") do={
        :set ($jsp->"pos") (($jsp->"pos") + 1);
        :set flag false;
        :return [[$GetFunc "tool.json.parseArray"] JSP=$jsp];
    }
    :if ($flag and $ch = "\"") do={
        :set ($jsp->"pos") (($jsp->"pos") + 1);
        :set flag false;
        :return [[$GetFunc "tool.json.parseString"] JSP=$jsp];
    }
    :if ($flag and $ch~"[eE0-9.+-]") do={
        :set flag false;
        :return [[$GetFunc "tool.json.parseNumber"] JSP=$jsp];
    }
    :if ($flag and $ch = "n") do={
        :local token [:pick ($jsp->"text") ($jsp->"pos") (($jsp->"pos") + 4)];
        :if ($token != "null") do={
            :local pos ($jsp->"pos");
            :error "tool.json.parseSwitch: pos: $pos, expected null";
        } else {
            :set ($jsp->"pos") (($jsp->"pos") + 4);
            :set flag false;
            :return $Nil;
        }
    }
    :if ($flag and $ch = "t") do={
        :local token [:pick ($jsp->"text") ($jsp->"pos") (($jsp->"pos") + 4)];
        :if ($token != "true") do={
            :local pos ($jsp->"pos");
            :error "tool.json.parseSwitch: pos: $pos, expected true";
        } else {
            :set ($jsp->"pos") (($jsp->"pos") + 4);
            :set flag false;
            :return true;
        }
    }
    :if ($flag and $ch = "f") do={
        :local token [:pick ($jsp->"text") ($jsp->"pos") (($jsp->"pos") + 5)];
        :if ($token != "false") do={
            :local pos ($jsp->"pos");
            :error "tool.json.parseSwitch: pos: $pos, expected false";
        } else {
            :set ($jsp->"pos") (($jsp->"pos") + 5);
            :set flag false;
            :return false;
        }
    }
    # unknown char
    :local pos ($jsp->"pos");
    :local t [:pick ($jsp->"text") $pos ($pos+1000)];
    :error "tool.json.parseSwitch: pos: $pos, unexpected character: $ch, $t";
}


# $loads
# kwargs: Str=<str>                 string to parse
# return: <obj>                     object
:local loads do={
    #DEFINE global
    :global IsStr;
    :global GetFunc;
    # check
    :if (![$IsStr $Str]) do={
        :error "tool.json.loads: require \$Str";
    }
    :if ($Str = "") do={
        :error "tool.json.loads: empty \$Str";
    }
    # make json parse array
    :local jsp {
        "text"=$Str;
        "pos"=0;
        "len"=[:len $Str];
    };
    :local result [[$GetFunc "tool.json.parseSwitch"] JSP=$jsp];
    :return $result;
}


# $makeIndent
# kwargs: JSF=<array>                json format array
:local makeIndent do={
    :local result "";
    :local indent "";
    :if (($JSF->"indent") >= 0) do={
        # new line
        :set result ($result . ("\n"));
        # make indent
        :for i from=1 to=($JSF->"indent") step=1 do={
            :set indent ($indent . " ");
        }
        :for i from=1 to=($JSF->"indentCount") step=1 do={
            :set result ($result . $indent);
        }
    }
    :return $result;
}


# $formatObject
# kwargs: JSF=<array>                json format array
:local formatObject do={
    #DEFINE global
    :global NewArray;
    :global GetFunc;
    # local
    :local jsf $JSF;
    :if ([:len ($jsf->"obj")] = 0) do={
        :return "{}";
    }
    :local result "{";
    # prepare indent
    :local njsf [$NewArray ];
    :set ($njsf->"indent") ($jsf->"indent");
    :set ($njsf->"indentCount") (($jsf->"indentCount") + 1);
    :set ($njsf->"ensureASCII") ($jsf->"ensureASCII");
    :local indent [[$GetFunc "tool.json.makeIndent"] JSF=$njsf];
    # make indent
    :foreach k,v in ($jsf->"obj") do={
        :if ($result = "{") do={
            :set result ($result . $indent);
        } else {
            :if (($jsf->"indent") >= 0) do={
                :set result ("$result," . $indent);
            } else {
                :set result "$result, ";
            }
        }
        :set ($njsf->"obj") $v;
        :local vStr [[$GetFunc "tool.json.formatSwitch"] JSF=$njsf];
        :set result ($result . "\"$k\": $vStr");
    }
    :set result ($result . [[$GetFunc "tool.json.makeIndent"] JSF=$jsf] . "}");
    :return $result;
}


# $formatArray
# kwargs: JSF=<array>                json format array
:local formatArray do={
    #DEFINE global
    :global NewArray;
    :global GetFunc;
    # local
    :local jsf $JSF;
    :if ([:len ($jsf->"obj")] = 0) do={
        :return "[]";
    }
    :local result "[";
    # prepare indent
    :local njsf [$NewArray ];
    :set ($njsf->"indent") ($jsf->"indent");
    :set ($njsf->"indentCount") (($jsf->"indentCount") + 1);
    :set ($njsf->"ensureASCII") ($jsf->"ensureASCII");
    :local indent [[$GetFunc "tool.json.makeIndent"] JSF=$njsf];
    # make indent
    :foreach k,v in ($jsf->"obj") do={
        :if ($result = "[") do={
            :set result ($result . $indent);
        } else {
            :if (($jsf->"indent") >= 0) do={
                :set result ("$result," . $indent);
            } else {
                :set result "$result, ";
            }
        }
        :set ($njsf->"obj") $v;
        :local vStr [[$GetFunc "tool.json.formatSwitch"] JSF=$njsf];
        :set result ($result . $vStr);
    }
    :set result ($result . [[$GetFunc "tool.json.makeIndent"] JSF=$jsf] . "]");
    :return $result;
}


# $formatString
# kwargs: JSF=<array>                json format array
:local formatString do={
    #DEFINE global
    :global DecodeUtf8;
    :global GetFunc;
    # local
    :local jsf $JSF;
    :local obj ($jsf->"obj");
    :local decoded [$DecodeUtf8 $obj];
    :return "\"$decoded\"";
}


# $formatSwitch
# kwargs: JSF=<array>               json format array
:local formatSwitch do={
    #DEFINE global
    :global IsStr;
    :global IsBool;
    :global IsNum;
    :global IsNil;
    :global IsArray;
    :global IsDict;
    :global IsEmpty;
    :global IsStr;
    :global GetFunc;
    # local
    :local jsf $JSF;
    :local obj ($jsf->"obj");
    # switch type
    :if ([$IsBool $obj]) do={
        :if ($obj = true) do={
            :return "true";
        } else {
            :return "false";
        }
    }
    :if ([$IsNum $obj]) do={
        :return "$obj";
    }
    :if ([$IsNil $obj]) do={
        :return "null";
    }
    :if ([$IsArray $obj]) do={
        :if ([$IsEmpty $obj]) do={
            :return [[$GetFunc "tool.json.formatArray"] JSF=$jsf];
        }
        :if ([$IsDict $obj]) do={
            :return [[$GetFunc "tool.json.formatObject"] JSF=$jsf];
        } else {
            :return [[$GetFunc "tool.json.formatArray"] JSF=$jsf];
        }
    }
    :if ([$IsStr $obj]) do={
        :return [[$GetFunc "tool.json.formatString"] JSF=$jsf];
    }
    # the rest type
    :return "\"$obj\"";
}


# $dumps
# kwargs: Obj=<obj>                 object to format
# kwargs: Indent=<num>              indentation, -1(default) or positive number
# kwargs: EnsureASCII=<bool>        ensure ascii or not, true(default)
:local dumps do={
    #DEFINE global
    :global IsNothing;
    :global ReadOption;
    :global TypeofNum;
    :global TypeofBool;
    :global GetFunc;
    # check
    :if ([$IsNothing $Obj]) do={
        :error "tool.json.dumps: require \$Obj";
    }
    :local indent [$ReadOption $Indent $TypeofNum -1];
    :local ensureASCII [$ReadOption $EnsureASCII $TypeofBool true];
    # make json format array
    :local jsf {
        "obj"=$Obj;
        "ensureASCII"=$ensureASCII;
        "indent"=$indent;
        "indentCount"=0;
    };
    :return [[$GetFunc "tool.json.formatSwitch"] JSF=$jsf];
}


:local package {
    "metaInfo"=$metaInfo;
    "skipWhitespace"=$skipWhitespace;
    "parseSwitch"=$parseSwitch;
    "parseObject"=$parseObject;
    "parseArray"=$parseArray;
    "parseString"=$parseString;
    "parseNumber"=$parseNumber;
    "loads"=$loads;
    "makeIndent"=$makeIndent;
    "formatSwitch"=$formatSwitch;
    "formatObject"=$formatObject;
    "formatArray"=$formatArray;
    "formatString"=$formatString;
    "dumps"=$dumps;
}
:return $package;
