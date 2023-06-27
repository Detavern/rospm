#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   tool.template
# ===================================================================
# ALL package level functions follows lower camel case.
# simple template utility
# Use {{ foo }} in the template to define a template variable,
# use {{ "{{" }} in the template to escaping.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="tool.template";
    "version"="0.4.0";
    "description"="template utility";
};


# $skipWhitespace
:local skipWhitespace do={
    :global tmplp;
    :while (($tmplp->"pos") < ($tmplp->"len") and ([:pick ($tmplp->"text") ($tmplp->"pos")] ~ "[ \r\n\t]")) do={
        :set ($tmplp->"pos") (($tmplp->"pos") + 1);
    }
}


# $skipUntilBrace
:local skipUntilBrace do={
    :global tmplp;
    :while (($tmplp->"pos") < ($tmplp->"len") and ([:pick ($tmplp->"text") ($tmplp->"pos")] != "{")) do={
        :set ($tmplp->"rendered") (($tmplp->"rendered") . [:pick ($tmplp->"text") ($tmplp->"pos")]);
        :set ($tmplp->"pos") (($tmplp->"pos") + 1);
    }
}


# $parseVariable
:local parseVariable do={
    #DEFINE global
    :global InKeys;
    :global GetFunc;
    # local
    :global tmplp;
    :local ch;
    :local nch;
    :local key "";
    :local flag true;
    :local first true;
    :while ($flag and ($tmplp->"pos") < ($tmplp->"len")) do={
        :set ch [:pick ($tmplp->"text") ($tmplp->"pos")];
        :if ($ch = " ") do={
            :set ($tmplp->"pos") (($tmplp->"pos") + 1);
            :set flag false;
        } else {
            :if ($first) do={
                # first character must match [A-Za-z]
                :if ($ch ~ "[A-Za-z]") do={
                    :set first false;
                    :set nch $ch;
                } else {
                    :error "tool.template.parseVariable: pos: $pos, first character must match [A-Za-z]";
                }
            } else {
                :if ($ch ~ "[A-Za-z0-9-]") do={
                    :set nch $ch;
                } else {
                    :error "tool.template.parseVariable: pos: $pos, next character must match [A-Za-z0-9-]";
                }
            }
            :set ($tmplp->"pos") (($tmplp->"pos") + 1);
            :set key ($key . $nch)
        }
    }
    # get value
    :local hasKey [$InKeys $key ($tmplp->"variables")];
    :if (!$hasKey) do={
        :error "tool.template.parseVariable: key: $key, not found in variables";
    }
    :local value (($tmplp->"variables")->$key)
    :set ($tmplp->"rendered") (($tmplp->"rendered") . $value);
}


# $parseStatement
:local parseStatement do={
    #DEFINE global
    :global GetFunc;
    # local
    :global tmplp;
    :local flag true;
    :local ch;
    :local chs;
    # skip whitespace
    [[$GetFunc "tool.template.skipWhitespace"]];
    :while ($flag and ($tmplp->"pos") < ($tmplp->"len")) do={
        :set ch [:pick ($tmplp->"text") ($tmplp->"pos")];
        :set chs [:pick ($tmplp->"text") ($tmplp->"pos") (($tmplp->"pos") + 2)];
        :if ($chs = "}}") do={
            :set ($tmplp->"pos") (($tmplp->"pos") + 2);
            :set flag false;
            :return [[$GetFunc "tool.template.parseSwitch"]];
        } else {
            :if ($ch = "\"" or $ch = "'") do={
                :set ($tmplp->"pos") (($tmplp->"pos") + 1);
                [[$GetFunc "tool.template.parseString"]];
            } else {
                [[$GetFunc "tool.template.parseVariable"]];
            }
            # skip whitespace after string
            [[$GetFunc "tool.template.skipWhitespace"]];
        }
    }
}


# $parseComment
:local parseComment do={
    #DEFINE global
    :global GetFunc;
    # local
    :global tmplp;
    :local flag true;
    :local ch;
    :local chs;
    # skip whitespace
    [[$GetFunc "tool.template.skipWhitespace"]];
    :while ($flag and ($tmplp->"pos") < ($tmplp->"len")) do={
        :set ch [:pick ($tmplp->"text") ($tmplp->"pos")];
        :set chs [:pick ($tmplp->"text") ($tmplp->"pos") (($tmplp->"pos") + 2)];
        :if ($chs = "#}") do={
            :set ($tmplp->"pos") (($tmplp->"pos") + 2);
            :set flag false;
        } else {
            :set ($tmplp->"pos") (($tmplp->"pos") + 1);
        }
    }
}


# $parseExpression
:local parseExpression do={
    #DEFINE global
    :global GetFunc;
    # local
    :global tmplp;
    :local flag true;
    :local ch;
    :local chs;
    # skip whitespace
    [[$GetFunc "tool.template.skipWhitespace"]];
    :error "tool.template.parseExpression: not implement";
}


# $parseString
:local parseString do={
    #DEFINE global
    :global UnicodeToUtf8;
    :global GetFunc;
    # local
    :global tmplp;
    :local ch;
    :local nch;
    :local result "";
    :local flag true;
    :while ($flag and ($tmplp->"pos") < ($tmplp->"len")) do={
        :set ch [:pick ($tmplp->"text") ($tmplp->"pos")];
        :if ($ch = "\"" or $ch = "'") do={
            :set ($tmplp->"pos") (($tmplp->"pos") + 1);
            :set flag false;
        } else {
            :if ($ch = "\\") do={
                # char escape
                :local ch2 [:pick ($tmplp->"text") (($tmplp->"pos") + 1)];
                :if ($ch2 = "u") do={
                    # unicode escape
                    :local unicodeStr [:pick ($tmplp->"text") (($tmplp->"pos") + 2) (($tmplp->"pos") + 6)];
                    :local unicode [:tonum "0x$unicodeStr"];
                    :if ($unicode >= 0xD800 and $utf <= 0xDFFF) do={
                        # unicode pair surrogate
                        # \uxxxx\uxxxx 12 chars
                        :local surrogateHigh (($unicode & 0x3FF) << 10);
                        :local surrogateLowStr [:pick ($tmplp->"text") (($tmplp->"pos") + 8) (($tmplp->"pos") + 12)];
                        :local surrogateLow ([:tonum "0x$surrogateLowStr"] & 0x3FF);
                        :set unicode ($surrogateHigh | $surrogateLow | 0x10000);
                        :set ($tmplp->"pos") (($tmplp->"pos") + 12);
                    } else {
                        # basic multilingual plane
                        # \uxxxx 6 chars
                        :set ($tmplp->"pos") (($tmplp->"pos") + 6);
                    }
                    # convert code point to utf-8 str
                    :set nch [$UnicodeToUtf8 $unicode];
                } else {
                    # other escape
                    :if ($ch2 ~ "[\\bfnrt\"]") do={
                        :set nch [[:parse "(\"\\$ch2\")"]];
                        :set ($tmplp->"pos") (($tmplp->"pos") + 2);
                    } else {
                        :if ($ch2 = "/") do={
                            :set ($tmplp->"pos") (($tmplp->"pos") + 2);
                            :set nch $ch2;
                        } else {
                            :local pos ($tmplp->"pos");
                            :error "tool.template.parseString: pos: $pos, expected token after \\";
                        }
                    }
                }
            } else {
                :set nch $ch;
                :set ($tmplp->"pos") (($tmplp->"pos") + 1);
            }
            :set result ($result . $nch)
        }
    }
    # skip whitespace
    :set ($tmplp->"rendered") (($tmplp->"rendered") . $result);
}


# $parseSwitch
:local parseSwitch do={
    #DEFINE global
    :global Print;
    :global GetFunc;
    # local
    :global tmplp;
    :local chs;
    :local flag true;
    # skip
    [[$GetFunc "tool.template.skipUntilBrace"]];
    :set chs [:pick ($tmplp->"text") ($tmplp->"pos") (($tmplp->"pos") + 2)];
    # switch token
    :if ($flag and $chs = "{{") do={
        :set ($tmplp->"pos") (($tmplp->"pos") + 2);
        :set flag false;
        :return [[$GetFunc "tool.template.parseStatement"]];
    }
    :if ($flag and $chs = "{#") do={
        :set ($tmplp->"pos") (($tmplp->"pos") + 2);
        :set flag false;
        :return [[$GetFunc "tool.template.parseComment"]];
    }
    :if ($flag and $chs = "{%") do={
        :set ($tmplp->"pos") (($tmplp->"pos") + 2);
        :set flag false;
        :return [[$GetFunc "tool.template.parseExpression"]];
    }
    # unknown char
    :if ($flag) do={
        :set ($tmplp->"rendered") (($tmplp->"rendered") . $chs);
        :set ($tmplp->"pos") (($tmplp->"pos") + 2);
        :if (($tmplp->"pos") < ($tmplp->"len")) do={
            [[$GetFunc "tool.template.parseSwitch"]];
        }
    }
}


# $render
# render the source template by an array with keys.
# kwargs: Template=<str>                source template
# kwargs: Variables=<array>             variables
# return: <str>                         rendered
:local render do={
    #DEFINE global
    :global IsStr;
    :global IsArray;
    :global GetFunc;
    # check
    :if (![$IsStr $Template]) do={
        :error "tool.template.render: require \$Template";
    }
    :if (![$IsArray $Variables]) do={
        :error "tool.template.render: require \$Variables";
    }
    :if ($pTemplate = "") do={
        :error "tool.template.render: empty \$Template";
    }
    # make template parse array
    :global tmplp {
        "text"=$Template;
        "pos"=0;
        "len"=[:len $Template];
        "variables"=$Variables;
        "rendered"="";
    };
    [[$GetFunc "tool.template.parseSwitch"]];
    :local result ($tmplp->"rendered");
    :set tmplp;
    :return $result;
}


:local package {
    "metaInfo"=$metaInfo;
    "skipWhitespace"=$skipWhitespace;
    "skipUntilBrace"=$skipUntilBrace;
    "parseSwitch"=$parseSwitch;
    "parseStatement"=$parseStatement;
    "parseComment"=$parseComment;
    "parseExpression"=$parseExpression;
    "parseString"=$parseString;
    "parseVariable"=$parseVariable;
    "render"=$render;
}
:return $package;
