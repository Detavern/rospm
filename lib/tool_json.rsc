# Based on Chupakabra303 and Winand's JSON parser for RouterOS.
# https://github.com/Winand/mikrotik-json-parser
# http://www.embest.ru/mikrotik/json-parser-script
#
# For loading json string
# This parser can load validated json string into an array object with following limitations:
# - the variable length limitation is 4096, so your json string length should be less than 4096.
# - the parser can load validated json string DOES NOT mean the original json string is validated.
#   there is the situation that original json has format error but the parser could still parse it.
# You can check the test file `tests/tests_tool_json.rsc` for detail.

:local metaInfo {
    "name"="tool.json";
    "version"="0.1.0";
    "description"="json loads and dumps";
};


# $skipWhitespace
# kwargs: JS=<array>                js array
:local skipWhitespace do={
    :while (($JS->"pos") < ($JS->"len") and ([:pick ($JS->"text") ($JS->"pos")] ~ "[ \r\n\t]")) do={
        :set ($JS->"pos") (($JS->"pos") + 1);
    }
}


# $parseObject
# kwargs: JS=<array>                js array
:local parseObject do={
    #DEFINE global
    :global NewArray;
    :global GetFunc;
    # local
    :local js $JS;
    :local flag true;
    :local ch;
    :local key;
    :local value;
    :local result [$NewArray ];
    # skip whitespace
    [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
    :while ($flag and ($js->"pos") < ($js->"len")) do={
        :set ch [:pick ($js->"text") ($js->"pos")];
        :if ($ch = "}") do={
            :set ($js->"pos") (($js->"pos") + 1);
            :set flag false;
        } else {
            :if ($ch != "\"") do={
                :local pos ($js->"pos");
                :error "tool.json.parseObject: pos: $pos, expected \" after {"
            } else {
                # key
                :set ($js->"pos") (($js->"pos") + 1);
                :set key [[$GetFunc "tool.json.parseString"] JS=$js];
                # delimiter between k,v
                [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
                :set ch [:pick ($js->"text") ($js->"pos")];
                :if ($ch != ":") do={
                    :local pos ($js->"pos");
                    :error "tool.json.parseObject: pos: $pos, expected delimiter : between k,v";
                } else {
                    :set ($js->"pos") (($js->"pos") + 1);
                    # value
                    :set value [[$GetFunc "tool.json.parseSwitch"] JS=$js];
                    :set ($result->$key) $value;
                    # delimiter after k,v
                    :set ch [:pick ($js->"text") ($js->"pos")];
                    :if ($ch = ",") do={
                        :set ($js->"pos") (($js->"pos") + 1);
                        [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
                    } else {
                        [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
                        :set ch [:pick ($js->"text") ($js->"pos")];
                        :if ($ch != "}") do={
                            :local pos ($js->"pos");
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
# kwargs: JS=<array>                js array
:local parseArray do={
    #DEFINE global
    :global NewArray;
    :global GetFunc;
    # local
    :local js $JS;
    :local flag true;
    :local ch;
    :local value;
    :local result [$NewArray ];
    # skip whitespace
    [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
    :while ($flag and ($js->"pos") < ($js->"len")) do={
        :set ch [:pick ($js->"text") ($js->"pos")];
        :if ($ch = "]") do={
            :set ($js->"pos") (($js->"pos") + 1);
            :set flag false;
        } else {
            :set value [[$GetFunc "tool.json.parseSwitch"] JS=$js];
            :set ($result->[:len $result]) $value;
            :set ch [:pick ($js->"text") ($js->"pos")];
            :if ($ch = ",") do={
                :set ($js->"pos") (($js->"pos") + 1);
                [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
            } else {
                [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
                :set ch [:pick ($js->"text") ($js->"pos")];
                :if ($ch != "]") do={
                    :local pos ($js->"pos");
                    :error "tool.json.parseArray: pos: $pos, expected delimiter ] after all value";
                }
            }
        }
    }
    :return $result;
}


# $parseString
# kwargs: JS=<array>                js array
:local parseString do={
    #DEFINE global
    :global Encode;
    :global GetFunc;
    # local
    :local js $JS;
    :local ch;
    :local nch;
    :local result "";
    :local flag true;
    :while ($flag and ($js->"pos") < ($js->"len")) do={
        :set ch [:pick ($js->"text") ($js->"pos")];
        :if ($ch = "\"") do={
            :set ($js->"pos") (($js->"pos") + 1);
            :set flag false;
        } else {
            :if ($ch = "\\") do={
                # char escape
                :local ch2 [:pick ($js->"text") (($js->"pos") + 1)];
                :if ($ch2 = "u") do={
                    # unicode escape
                    :local unicodeStr [:pick ($js->"text") (($js->"pos") + 2) (($js->"pos") + 6)];
                    :local unicode [:tonum "0x$unicodeStr"];
                    :if ($unicode >= 0xD800 and $utf <= 0xDFFF) do={
                        # unicode pair surrogate
                        # \uxxxx\uxxxx 12 chars
                        :local surrogateHigh (($unicode & 0x3FF) << 10);
                        :local surrogateLowStr [:pick ($js->"text") (($js->"pos") + 8) (($js->"pos") + 12)];
                        :local surrogateLow ([:tonum "0x$surrogateLowStr"] & 0x3FF);
                        :set unicode ($surrogateHigh | $surrogateLow | 0x10000);
                        :set ($js->"pos") (($js->"pos") + 12);
                    } else {
                        # basic multilingual plane
                        # \uxxxx 6 chars
                        :set ($js->"pos") (($js->"pos") + 6);
                    }
                    # convert code point to utf-8 str
                    :set nch [$Encode $unicode];
                } else {
                    # other escape
                    :if ($ch2 ~ "[\\bfnrt\"]") do={
                        :set nch [[:parse "(\"\\$ch2\")"]];
                        :set ($js->"pos") (($js->"pos") + 2);
                    } else {
                        :if ($ch2 = "/") do={
                            :set ($js->"pos") (($js->"pos") + 2);
                            :set nch $ch2;
                        } else {
                            :local pos ($js->"pos");
                            :error "tool.json.parseString: pos: $pos, expected token after \\";
                        }
                    }
                }
            } else {
                :set nch $ch;
                :set ($js->"pos") (($js->"pos") + 1);
            }
            :set result ($result . $nch)
        }
    }
    # skip whitespace
    :return $result;
}


# $parseNumber
# kwargs: JS=<array>                js array
:local parseNumber do={
    #DEFINE global
    :global IsNum;
    :global GetFunc;
    # local
    :local js $JS;
    :local flag true;
    :local ch;
    :local startPos ($js->"pos");
    :while ($flag and ($js->"pos") < ($js->"len")) do={
        :set ch [:pick ($js->"text") ($js->"pos")];
        :if ($ch ~ "[eE0-9.+-]") do={
            :set ($js->"pos") (($js->"pos") + 1);
        } else {
            :set flag false;
        }
    }
    # number
    :local numberStr [:pick ($js->"text") $startPos ($js->"pos")];
    :local number [:tonum $numberStr];
    :if ([$IsNum $number]) do={
        :return $number;
    } else {
        :return $numberStr;
    }
}


# $parseSwitch
# kwargs: JS=<array>                js array
:local parseSwitch do={
    #DEFINE global
    :global Nil;
    :global IsStr;
    :global GetFunc;
    # local
    :local js $JS;
    :local ch;
    :local flag true;
    # skip
    [[$GetFunc "tool.json.skipWhitespace"] JS=$js];
    :set ch [:pick ($js->"text") ($js->"pos")];
    # switch token
    :if ($flag and $ch = "{") do={
        :set ($js->"pos") (($js->"pos") + 1);
        :set flag false;
        :return [[$GetFunc "tool.json.parseObject"] JS=$js];
    }
    :if ($flag and $ch = "[") do={
        :set ($js->"pos") (($js->"pos") + 1);
        :set flag false;
        :return [[$GetFunc "tool.json.parseArray"] JS=$js];
    }
    :if ($flag and $ch = "\"") do={
        :set ($js->"pos") (($js->"pos") + 1);
        :set flag false;
        :return [[$GetFunc "tool.json.parseString"] JS=$js];
    }
    :if ($flag and $ch~"[eE0-9.+-]") do={
        :set flag false;
        :return [[$GetFunc "tool.json.parseNumber"] JS=$js];
    }
    :if ($flag and $ch = "n") do={
        :local token [:pick ($js->"text") ($js->"pos") (($js->"pos") + 4)];
        :if ($token != "null") do={
            :local pos ($js->"pos");
            :error "tool.json.parseSwitch: pos: $pos, expected null";
        } else {
            :set ($js->"pos") (($js->"pos") + 4);
            :set flag false;
            :return $Nil;
        }
    }
    :if ($flag and $ch = "t") do={
        :local token [:pick ($js->"text") ($js->"pos") (($js->"pos") + 4)];
        :if ($token != "true") do={
            :local pos ($js->"pos");
            :error "tool.json.parseSwitch: pos: $pos, expected true";
        } else {
            :set ($js->"pos") (($js->"pos") + 4);
            :set flag false;
            :return true;
        }
    }
    :if ($flag and $ch = "f") do={
        :local token [:pick ($js->"text") ($js->"pos") (($js->"pos") + 5)];
        :if ($token != "false") do={
            :local pos ($js->"pos");
            :error "tool.json.parseSwitch: pos: $pos, expected false";
        } else {
            :set ($js->"pos") (($js->"pos") + 5);
            :set flag false;
            :return false;
        }
    }
    # unknown char
    :local pos ($js->"pos");
    :local t [:pick ($js->"text") $pos ($pos+1000)];
    :error "tool.json.parseSwitch: pos: $pos, unexpected character: $ch, $t";
}


# $loads
# kwargs: Str=<str>                 string to parse
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
    # local
    :local js {
        "text"=$Str;
        "pos"=0;
        "len"=[:len $Str];
    };
    :local result [[$GetFunc "tool.json.parseSwitch"] JS=$js];
    :return $result;
}



# $dumps
:local dumps do={
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
    "dumps"=$dumps;
}
:return $package;
