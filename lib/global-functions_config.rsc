# Global Functions | Config
# =========================================================
# ALL global functions follows upper camel case.
# Configuration file management tool.
#
# USE as your wish

:local metaInfo {
    "name"="global-functions.config";
    "version"="0.2.0";
    "description"="global functions for configuration management";
    "global"=true;
};


# $GetConfig
# args: <str>                   <package name>
# return: <array->var>          config named array      
:global GetConfig do={
    # global declare
    :global RSplit;
    :global Replace;
    :global IsEmpty;
    :global ValidatePackageContent;
    # replace
    :local pkgName $1;
    :local fileName [$Replace $pkgName "." "_"];
    :local idList [/system script find name=$fileName];
    :if ([$IsEmpty $idList]) do={
        :error "Global.Package.GetConfig: script \"$fileName\" not found";
    }
    # parse code and get result;
    :local pSource [:parse [/system script get ($idList->0) source]];
    :local pkg [$pSource ];
    :local va {"name"=$pkgName;"type"="config"};
    if (![$ValidatePackageContent $pkg $va]) do={
        :error "Global.Package.GetConfig: could not validate target package";
    }
    :return $pkg;
}


# $CreateConfig
# create a new configuration package.
# args: <str>                   <config package name>
# args: <array->str>            config array
# opt kwargs: Output=<str>      output format: file(default), str, array
# opt kwargs: Owner=<str>       script owner
# return: <str>                 string of config package
:global CreateConfig do={
    # global declare
    :global IsStr;
    :global IsArray;
    :global IsEmpty;
    :global Join;
    :global DumpVar;
    :global NewArray;
    :global TypeofStr;
    :global Replace;
    :global ReadOption;
    :global ScriptLengthLimit;
    # check params
    :if (![$IsStr $1]) do={
        :error "Global.Package.CreateConfig: \$1 should be str";
    }
    :if (![$IsArray $2]) do={
        :error "Global.Package.CreateConfig: \$2 should be a k,v array";
    }
    # local
    :local pkgName $1;
    :local config $2;
    :local fileName [$Replace $pkgName "." "_"];
    :local pOutput [$ReadOption $Output $TypeofStr "file"];
    :local pOwner [$ReadOption $Owner $TypeofStr ""];
    :local LSL [$NewArray ];
    :local configArray {
        "metaInfo"="noquote:\$metaInfo";
    };
    # TODO: better clock info
    :local clock [/system clock print as-value];
    :local date ($clock->"date");
    :local time ($clock->"time");
    # dump meta
    :local meta {
        "name"=$pkgName;
        "type"="config";
        "created_at"="$date $time";
        "last_modify"="$date $time";
    };
    :set LSL ($LSL, [$DumpVar "metaInfo" $meta Output="array" Return=false]);
    :set ($LSL->[:len $LSL]) "";
    # dump additions
    :foreach k,v in $config do={
        :if ([$IsArray $v]) do={
            :if ($k != "metaInfo") do={
                :set ($configArray->$k) "noquote:\$$k";
                :set LSL ($LSL, [$DumpVar $k $v Output="array" Return=false]);
                :set ($LSL->[:len $LSL]) "";
            }
        } else {
            :set ($configArray->$k) $v;
        }
    }
    # dump config
    :set LSL ($LSL, [$DumpVar "config" $configArray Output="array"]);
    :set ($LSL->[:len $LSL]) "";
    # output array
    :if ($pOutput = "array") do={
        :return $LSL;
    }
    # join
    :local result [$Join ("\r\n") $LSL];
    # check script length
    :if ([:len $result] >= $ScriptLengthLimit) do={
        :error "Global.Package.CreateConfig: configuration file length reachs 30,000 characters limit, try split it";
    }
    # output str
    :if ($pOutput = "str") do={
        :return $result;
    }
    # output file
    :if ($pOutput = "file") do={
        :if ([$IsEmpty [/system script find name=$fileName]]) do={
            :if ($pOwner = "") do={
                /system script add name=$fileName source=$result;
            } else {
                /system script add name=$fileName source=$result owner=$pOwner;
            }
        } else {
            :error "Global.Package.CreateConfig: same configuration file already exist!";
        }
    }
}


# $UpdateConfig
# update configure with target array.
# args: <str>                   <config package name>
# args: <array>                 config array
# opt kwargs: Output=<str>      output format: file(default), str, array
:global UpdateConfig do={
    # global declare
    :global GetConfig;
    :global IsStr;
    :global IsArray;
    :global DumpVar;
    :global Join;
    :global FindPackage;
    :global TypeofStr;
    :global ReadOption;
    :global ScriptLengthLimit;
    :global NewArray;
    :global Replace;
    # check params
    :if (![$IsStr $1]) do={
        :error "Global.Package.UpdateConfig: \$1 should be str";
    };
    :if (![$IsArray $2]) do={
        :error "Global.Package.UpdateConfig: \$2 should a k,v array";
    };
    # local
    :local pkgName $1;
    :local config [$GetConfig $pkgName];
    :local fileName [$Replace $pkgName "." "_"];
    :local pOutput [$ReadOption $Output $TypeofStr "file"];
    :local pOwner [/system script get [/system script find name=$fileName] owner];
    :local LSL [$NewArray ];
    :local configArray {
        "metaInfo"="noquote:\$metaInfo";
    };
    # TODO: better clock info
    :local clock [/system clock print as-value];
    :local date ($clock->"date");
    :local time ($clock->"time");
    # update meta and dump it
    :local meta ($config->"metaInfo");
    :set ($meta->"last_modify") "$date $time";
    :set LSL ($LSL, [$DumpVar "metaInfo" $meta Output="array" Return=false]);
    :set ($LSL->[:len $LSL]) "";
    # update by input
    :foreach k,v in $2 do={
        :set ($config->$k) $v;
    }
    # dump addition array
    :foreach k,v in $config do={
        :if ([$IsArray $v]) do={
            :if ($k != "metaInfo") do={
                :set ($configArray->$k) "noquote:\$$k";
                :set LSL ($LSL, [$DumpVar $k $v Output="array" Return=false]);
                :set ($LSL->[:len $LSL]) "";
            }
        } else {
            :set ($configArray->$k) $v;
        }
    }
    # dump config array
    :set LSL ($LSL, [$DumpVar "config" $configArray Output="array"]);
    :set ($LSL->[:len $LSL]) "";
    # output array
    :if ($pOutput = "array") do={
        :return $LSL;
    }
    # join
    :local result [$Join ("\r\n") $LSL];
    # check script length
    :if ([:len $result] >= $ScriptLengthLimit) do={
        :error "Global.Package.UpdateConfig: configuration file length reachs 30,000 characters limit, try split it";
    }
    # output str
    :if ($pOutput = "str") do={
        :return $result;
    }
    # output file
    /system script set [$FindPackage $pkgName] source=$result owner=$pOwner;
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
