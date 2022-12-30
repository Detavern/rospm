# core package meta list
:local packageList {
    {
        "name"="global-variables";
        "description"="global variable package";
        "version"="0.3.1";
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
        "version"="0.3.1";
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
            "ReadOption";
            "InKeys";
            "InValues";
            "TypeRecovery";
            "Input";
            "InputV";
        };
    };
    {
        "name"="global-functions.array";
        "description"="global functions for array related operation";
        "version"="0.3.1";
        "global"=true;
        "global-functions"={
            "Append";
            "Appends";
            "Prepend";
            "Insert";
            "Extend";
            "Reverse";
        };
    };
    {
        "name"="global-functions.string";
        "description"="global functions for string related operation";
        "version"="0.3.1";
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
        "name"="global-functions.random";
        "description"="global functions for random related operation";
        "version"="0.3.1";
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
        "version"="0.4.0";
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
        "description"="global functions for datetime operation";
        "version"="0.3.1";
        "global"=true;
        "global-functions"={
            "IsSDT";
            "IsDatetime";
            "IsTimedelta";
            "GetCurrentClock";
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
            "GetTimedelta";
        };
    };
    {
        "name"="global-functions.package";
        "description"="global functions for package operation";
        "version"="0.3.1";
        "global"=true;
        "global-functions"={
            "FindPackage";
            "ValidatePackageContent";
            "ValidatePackage";
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
        "description"="global functions for configuration management";
        "version"="0.4.0";
        "global"=true;
        "global-functions"={
            "LoadGlobalEnv";
            "PrintGlobalEnv";
            "GetConfig";
            "UpdateConfig";
            "RegisterConfig";
            "CreateConfig";
            "RemoveConfig";
        };
    };
    {
        "name"="global-functions.unicode";
        "description"="Global Package for unicode related operation";
        "version"="0.3.1";
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
        "version"="0.4.0";
        "global"=true;
        "global-functions"={
            "UniqueArray";
        };
    };
    {
        "name"="global-helpers";
        "description"="global helper package";
        "version"="0.3.1";
        "global"=true;
        "global-functions"={
            "itemsFoundEnsureOneEnabled";
            "addItemByTemplate";
            "findOneActiveItem";
            "findOneEnabledItem";
            "findOneDisabledItem";
            "findAllEnabledItems";
            "getAttrsByIDList";
            "findAllItemsByTemplate";
            "setItemAttrByTemplate";
        };
    };
    {
        "name"="ddns";
        "description"="ddns schedule framework";
        "version"="0.3.1";
    };
    {
        "name"="ddns.getter";
        "description"="ddns ip getter";
        "version"="0.3.1";
    };
    {
        "name"="ddns.provider.cloudflare";
        "description"="ddns provider functions for cloudflare";
        "version"="0.3.1";
    };
    {
        "name"="interface.ethernet";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="interface.list";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="ip.address";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="ip.firewall.address-list";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="ip.firewall.raw";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="ip.route";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="ip.route.rule";
        "description"="";
        "version"="0.3.1";
    };
    {
        "name"="rspm";
        "description"="rspm";
        "version"="0.3.1";
    };
    {
        "name"="rspm.config";
        "description"="rspm configuration tools";
        "version"="0.4.0";
    };
    {
        "name"="rspm.feature";
        "description"="rspm feature tools";
        "version"="0.4.0";
    };
    {
        "name"="rspm.reset";
        "description"="rspm configuration reset tools";
        "version"="0.3.1";
    };
    {
        "name"="rspm.state";
        "description"="rspm package state tools";
        "version"="0.3.1";
    };
    {
        "name"="tool.file";
        "description"="file utility";
        "version"="0.3.1";
    };
    {
        "name"="tool.http";
        "description"="http utility";
        "version"="0.3.1";
    };
    {
        "name"="tool.json";
        "description"="json loads and dumps";
        "version"="0.3.1";
    };
    {
        "name"="tool.remote";
        "description"="remote script load tools";
        "version"="0.3.1";
    };
};

# core package meta mapping, use with list.
:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.array"=2;
    "global-functions.string"=3;
    "global-functions.random"=4;
    "global-functions.cache"=5;
    "global-functions.datetime"=6;
    "global-functions.package"=7;
    "global-functions.config"=8;
    "global-functions.unicode"=9;
    "global-functions.misc"=10;
    "global-helpers"=11;
    "ddns"=12;
    "ddns.getter"=13;
    "ddns.provider.cloudflare"=14;
    "interface.ethernet"=15;
    "interface.list"=16;
    "ip.address"=17;
    "ip.firewall.address-list"=18;
    "ip.firewall.raw"=19;
    "ip.route"=20;
    "ip.route.rule"=21;
    "rspm"=22;
    "rspm.config"=23;
    "rspm.feature"=24;
    "rspm.reset"=25;
    "rspm.state"=26;
    "tool.file"=27;
    "tool.http"=28;
    "tool.json"=29;
    "tool.remote"=30;
}

# the minimum requirement packages of rspm
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
    "rspm.state";
    "rspm.reset";
    "rspm";
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
    "essentialPackageList"=$essentialPackageList;
}

:return $packageInfo;