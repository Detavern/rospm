# Global helpers
# =========================================================
# ALL global functions follows lower camel case.
#
# Helpers are some functions which can greatly help 
# the construction of a certain number of other functions
# or frequently invoked by them.
#
# USE if you known CLEARLY what you are doing.

:local metaInfo {
    "name"="global-helpers";
    "version"="0.0.1";
    "description"="global helper package";
};

# ensure one of specific internal ID item is enabled
# args: <str>           command
# args: <array->id>     array of id, result of /find
:global itemsFoundEnsureOneEnabled do={
    :foreach v in $2 do={
        # /interface ethernet
        :local cmdStr "$1 get number=$v disabled";
        :local cmdFunc [:parse $cmdStr];
        :if ([$cmdFunc]) do={
            # find a disabled one, then enable it
            :local cmdEnabledStr "$1 enable $v";
            :local cmdEnabledFunc [:parse $cmdEnabledStr];
            $cmdEnabledFunc;
        }
        :return true;
    }
}


# add item by a template
# args: <str>           command
# args: <array->str>    template 
:global addItemByTemplate do={
    # global declare
    :global IsNil;
    :global IsStr;
    # local
    :local cmdStr "$1 add";
    :foreach k,v in $2 do={
        :if (![$IsNil $v]) do={
            :if ([$IsStr $v]) do={
                :set cmdStr ($cmdStr . " $k=\"$v\"");
            } else {
                :set cmdStr ($cmdStr . " $k=$v");
            }
        }
    }
    # exec add function
    :local cmdFunc [:parse $cmdStr];
    :local internalID [$cmdFunc];
    :return $internalID;
}


# find a currently active item in id list, return nil if not exist
# args: <str>           command
# args: <array->id>     array of id, scope of search
# return: <id> or Nil
:global findOneActiveItem do={
    # global declare
    :global Nil;
    # local
    :foreach v in $2 do={
        :local cmdStr "$1 get number=$v active";
        :local cmdFunc [:parse $cmdStr];
        :if ([$cmdFunc]) do={
            # find an active one, return it
            :return $v;
        }
    }
    :return $Nil;
}


# find a currently enabled item in id list, return nil if not exist
# args: <str>           command
# args: <array->id>     array of id, scope of search
# return: <id> or Nil
:global findOneEnabledItem do={
    # global declare
    :global Nil;
    # local
    :foreach v in $2 do={
        :local cmdStr "$1 get number=$v disabled";
        :local cmdFunc [:parse $cmdStr];
        :if (![$cmdFunc]) do={
            # find an enabled one, return it
            :return $v;
        }
    }
    :return $Nil;
}


# find a currently disabled item in id list, return nil if not exist
# args: <str>           command
# args: <array->id>     array of id, scope of search
# return: <id> or Nil
:global findOneDisabledItem do={
    # global declare
    :global Nil;
    # local
    :foreach v in $2 do={
        :local cmdStr "$1 get number=$v disabled";
        :local cmdFunc [:parse $cmdStr];
        :if ([$cmdFunc]) do={
            # find an disabled one, return it
            :return $v;
        }
    }
    :return $Nil;
}

# TODO:
# find all currently enabled item in id list
# args: <str>           command
# args: <array->id>     array of id, scope of search
# return: <array->id>
:global findAllEnabledItems do={
    # global declare
    :global Nil;
    # local
    :local 
    :foreach v in $2 do={
        :local cmdStr "$1 get number=$v disabled";
        :local cmdFunc [:parse $cmdStr];
        :if (![$cmdFunc]) do={
            # find an enabled one, return it
            :return $v;
        }
    }
    :return $Nil;
}


# $getAttrsByIDList
# find items by a template and return an array
# args: <str>                   command
# args: <array->id>             array of id
# args: <str>                   name of attribute
# return: <array->v>
:global getAttrsByIDList do={
    # global declare
    :global IsNil;
    :global IsStr;
    :global IsNothing;
    :global IsBool;
    :global NewArray;
    :global Append;
    :global ReadOption;
    # local
    :local result [$NewArray];
    :foreach v in $2 do={
        :local cmdStr;
        :if ([$IsNothing $3]) do={
            :set cmdStr "$1 get number=$v";
        } else {
            :set cmdStr "$1 get number=$v $3";
        }
        :local cmdFunc [:parse $cmdStr];
        :local attrV [$cmdFunc];
        :set result [$Append $result $attrV];
    }
    :return $result;
}


# $findAllItemsByTemplate
# find items by a template and return an array
# args: <str>                   command
# args: <array->str>            template
# opt kwargs: Output=<str>      output format
:global findAllItemsByTemplate do={
    # global declare
    :global IsNil;
    :global IsStr;
    :global IsBool;
    :global TypeofStr;
    :global ReadOption;
    # global helper declare
    :global getAttrsByIDList;
    # local
    :local pOutput [$ReadOption $Output $TypeofStr "id"];
    :local cmdStr "$1 find";
    :foreach k,v in $2 do={
        :if (![$IsNil $v]) do={
            :if ([$IsStr $v]) do={
                :set cmdStr ($cmdStr . " $k=\"$v\"");
            } else {
                :if ([$IsBool $v]) do={
                    :if ($v) do={
                        :set cmdStr ($cmdStr . " $k=yes");
                    } else {
                        :set cmdStr ($cmdStr . " $k=no");
                    }
                } else {
                    :set cmdStr ($cmdStr . " $k=$v");
                }
            }    
        }
    }
    :local cmdFunc [:parse $cmdStr];
    :local idList [$cmdFunc];
    :if ($pOutput = "id") do={
        :return $idList;
    }
    :local rList [$getAttrsByIDList $1 $idList $pOutput];
    :return $rList;
}


# set item's attributes by a template
# args: <str>           command
# args: <id>            item's internal ID
# args: <array->str>    template
:global setItemAttrByTemplate do={
    # global declare
    :global IsNil;
    :global IsStr;
    :global IsBool;
    # local
    :local cmdStr "$1 set number=$2";
    :foreach k,v in $3 do={
        :if (![$IsNil $v]) do={
            :if ([$IsStr $v]) do={
                :set cmdStr ($cmdStr . " $k=\"$v\"");
            } else {
                :if ([$IsBool $v]) do={
                    :if ($v) do={
                        :set cmdStr ($cmdStr . " $k=yes");
                    } else {
                        :set cmdStr ($cmdStr . " $k=no");
                    }
                } else {
                    :set cmdStr ($cmdStr . " $k=$v");
                }
            }   
        }
    }
    :local cmdFunc [:parse $cmdStr];
    $cmdFunc;
}

# package info
:local package {
    "metaInfo"=$metaInfo;
    "global"=true;
}
:return $package;
