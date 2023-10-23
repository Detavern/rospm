# Code generated by script. DO NOT EDIT.

# core package meta list
:local packageList {
    {
        "name"="global-variables";
        "description"="global variable package";
        "version"="0.5.0";
        "global"=true;
        "global-variables"={
            "Nothing";
            "Nil";
            "EmptyArray";
            "TypeofNothing";
            "TypeofNil";
            "TypeofStr";
            "TypeofNum";
            "TypeofBool";
            "TypeofID";
            "TypeofTime";
            "TypeofIP";
            "TypeofIPPrefix";
            "TypeofIPv6";
            "TypeofIPv6Prefix";
            "TypeofArray";
            "SYSArchitectureName";
            "SYSBoardName";
            "SYSCPU";
            "SYSCPUCount";
            "SYSCPUFrequency";
            "SYSVersion";
            "ScriptLengthLimit";
            "VariableLengthLimit";
            "MonthsOfTheYear";
            "MonthsName";
            "CharToNum";
        };
    };
    {
        "name"="global-functions";
        "description"="global function package";
        "version"="0.5.0";
        "global"=true;
        "global-functions"={
            "IsNil";
            "IsNothing";
            "IsNum";
            "IsStr";
            "IsBool";
            "IsTime";
            "IsArray";
            "IsIP";
            "IsIPv6";
            "IsIPPrefix";
            "IsIPv6Prefix";
            "IsEmpty";
            "IsStrN";
            "IsArrayN";
            "IsDict";
            "NewArray";
            "Assert";
            "Print";
            "PrintK";
            "GetGlobal";
            "TypeRecovery";
            "ReadOption";
            "InKeys";
            "InValues";
            "Input";
            "InputV";
        };
    };
    {
        "name"="global-functions.array";
        "description"="Global functions are designed to perform array related operation.";
        "version"="0.5.1";
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
    {
        "name"="global-functions.string";
        "description"="global functions for string related operation";
        "version"="0.5.0";
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
    {
        "name"="global-functions.network";
        "description"="Global functions are designed to perform network calcuation.";
        "version"="0.5.1";
        "global"=true;
        "global-functions"={
            "ToIPPrefix";
            "IsCIDR";
            "ParseCIDR";
            "GetPool";
        };
    };
    {
        "name"="global-functions.random";
        "description"="global functions for random related operation";
        "version"="0.5.0";
        "global"=true;
        "global-functions"={
            "Random20CharHex";
            "RandomNumber";
            "RandomChoice";
        };
    };
    {
        "name"="global-functions.cache";
        "description"="global functions for cache operation";
        "version"="0.5.0";
        "global"=true;
        "global-functions"={
            "GlobalCacheFuncGet";
            "GlobalCacheFuncPut";
            "GlobalCacheFuncRemove";
            "GlobalCacheFuncRemovePrefix";
            "GlobalCacheFuncFlush";
            "GlobalCacheFuncStatus";
        };
    };
    {
        "name"="global-functions.datetime";
        "description"="Global functions are designed to perform datetime calcuation.";
        "version"="0.5.1";
        "global"=true;
        "global-functions"={
            "IsSDT";
            "IsDatetime";
            "IsTimedelta";
            "GetCurrentDate";
            "GetCurrentTime";
            "GetCurrentSDT";
            "ToTimedelta";
            "ToDatetime";
            "GetCurrentDatetime";
            "ToSDT";
            "IsLeapYear";
            "ShiftDatetime";
            "CompareDatetime";
            "GetTimeDiff";
            "GetTimedeltaDiff";
        };
    };
    {
        "name"="global-functions.package";
        "description"="Global functions are vital for the package operation.";
        "version"="0.5.1";
        "global"=true;
        "global-functions"={
            "FindPackage";
            "ValidateMetaInfo";
            "GetSource";
            "GetMeta";
            "ParseMetaSafe";
            "GetMetaSafe";
            "GetEnv";
            "PrintPackageInfo";
            "LoadPackage";
            "GetFunc";
            "DumpVar";
            "LoadVar";
            "SetGlobalVar";
            "LoadGlobalVar";
            "UnsetGlobalVar";
        };
    };
    {
        "name"="global-functions.config";
        "description"="Global functions are vital for the configuration management.";
        "version"="0.5.1";
        "global"=true;
        "global-functions"={
            "LoadGlobalEnv";
            "PrintGlobalEnv";
            "GetConfig";
            "UpdateConfig";
            "RegisterConfig";
            "CreateConfig";
            "RemoveConfig";
            "ListAllGlobals";
        };
    };
    {
        "name"="global-functions.unicode";
        "description"="Global Package for unicode related operation";
        "version"="0.5.0";
        "global"=true;
        "global-functions"={
            "ByteToChar";
            "CharToByte";
            "UnicodeToUtf8";
            "Utf8ToUnicode";
            "Utf8ToUnicodeEscaped";
            "EncodeUtf8";
            "DecodeUtf8";
        };
    };
    {
        "name"="global-functions.misc";
        "description"="global functions for miscellaneous collection";
        "version"="0.5.0";
        "global"=true;
        "global-functions"={
            "UniqueArray";
        };
    };
    {
        "name"="global-helpers";
        "description"="global helper package";
        "version"="0.5.0";
        "global"=true;
        "global-functions"={
            "helperEnsureOneEnabled";
            "helperEnsureOneDisabled";
            "helperAddByTemplate";
            "helperSetByTemplate";
            "helperFindByTemplate";
            "findOneEnabled";
            "findOneDisabled";
            "findOneActive";
            "findAllEnabled";
            "getAttrsByIDList";
        };
    };
    {
        "name"="ip.address";
        "description"="";
        "version"="0.5.0";
    };
    {
        "name"="routing.rule";
        "description"="routing rule tools";
        "version"="0.5.0";
    };
    {
        "name"="tool.remote";
        "description"="remote script load tools";
        "version"="0.5.0";
    };
    {
        "name"="interface.list";
        "description"="interface list related functions.";
        "version"="0.5.0";
    };
    {
        "name"="rospm";
        "description"="ROSPM package entrypoints";
        "version"="0.5.0";
    };
    {
        "name"="rospm.state";
        "description"="ROSPM package state tools";
        "version"="0.5.0";
    };
    {
        "name"="tool.json";
        "description"="json loads and dumps";
        "version"="0.5.0";
    };
    {
        "name"="rospm.reset";
        "description"="rospm configuration reset tools";
        "version"="0.5.0";
    };
    {
        "name"="cidr";
        "description"="collections of special CIDRs";
        "version"="0.5.0";
    };
    {
        "name"="ip.firewall.raw";
        "description"="";
        "version"="0.5.0";
    };
    {
        "name"="interface.ethernet";
        "description"="";
        "version"="0.5.0";
    };
    {
        "name"="ddns";
        "description"="ddns schedule framework";
        "version"="0.5.0";
    };
    {
        "name"="rospm.config";
        "description"="rospm configuration tools";
        "version"="0.5.0";
    };
    {
        "name"="routing.table";
        "description"="";
        "version"="0.5.0";
    };
    {
        "name"="ddns.getter";
        "description"="ddns ip getter";
        "version"="0.5.0";
    };
    {
        "name"="ddns.provider.cloudflare";
        "description"="ddns provider functions for cloudflare";
        "version"="0.5.0";
    };
    {
        "name"="tool.http";
        "description"="http utility";
        "version"="0.5.0";
    };
    {
        "name"="rospm.feature";
        "description"="rospm feature tools";
        "version"="0.5.0";
    };
    {
        "name"="ip.firewall.address.watcher";
        "description"="watch and store address on specific interface";
        "version"="0.5.0";
    };
    {
        "name"="ip.firewall.address";
        "description"="";
        "version"="0.5.0";
    };
    {
        "name"="rospm.action";
        "description"="The real action(like: install, upgrade, etc) behind the scenes. Should not be used directly.";
        "version"="0.5.0";
    };
    {
        "name"="tool.template";
        "description"="A simple template utility.";
        "version"="0.5.0";
    };
    {
        "name"="ip.route";
        "description"="";
        "version"="0.5.0";
    };
    {
        "name"="tool.file";
        "description"="file utility";
        "version"="0.5.0";
    };
};

# core package meta mapping, use with list.
:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.array"=2;
    "global-functions.string"=3;
    "global-functions.network"=4;
    "global-functions.random"=5;
    "global-functions.cache"=6;
    "global-functions.datetime"=7;
    "global-functions.package"=8;
    "global-functions.config"=9;
    "global-functions.unicode"=10;
    "global-functions.misc"=11;
    "global-helpers"=12;
    "ip.address"=13;
    "routing.rule"=14;
    "tool.remote"=15;
    "interface.list"=16;
    "rospm"=17;
    "rospm.state"=18;
    "tool.json"=19;
    "rospm.reset"=20;
    "cidr"=21;
    "ip.firewall.raw"=22;
    "interface.ethernet"=23;
    "ddns"=24;
    "rospm.config"=25;
    "routing.table"=26;
    "ddns.getter"=27;
    "ddns.provider.cloudflare"=28;
    "tool.http"=29;
    "rospm.feature"=30;
    "ip.firewall.address.watcher"=31;
    "ip.firewall.address"=32;
    "rospm.action"=33;
    "tool.template"=34;
    "ip.route"=35;
    "tool.file"=36;
}

# the minimum requirement packages of rospm
:local essentialPackageList {
    "global-variables";
    "global-functions";
    "global-functions.array";
    "global-functions.string";
    "global-functions.cache";
    "global-functions.datetime";
    "global-functions.package";
    "global-functions.config";
    "global-functions.unicode";
    "global-functions.misc";
    "tool.http";
    "tool.remote";
    "rospm.feature";
    "rospm.state";
    "rospm.action";
    "rospm.reset";
    "rospm";
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
    "essentialPackageList"=$essentialPackageList;
}

:return $packageInfo;