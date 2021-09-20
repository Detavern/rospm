# core package meta list
:local packageList {
    {
        "name"="global-variables";
        "description"="global variable package";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions";
        "description"="global function package";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.array";
        "description"="global functions for array related operation";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.string";
        "description"="global functions for string related operation";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.cache";
        "description"="global functions for cache operation";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.datetime";
        "description"="global functions for datetime operation";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.package";
        "description"="global functions for package operation";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.unicode";
        "description"="Global Package for unicode related operation";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-functions.misc";
        "description"="global functions for miscellaneous collection";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="global-helpers";
        "description"="global helper package";
        "version"="0.1.1";
        "global"=true;
    };
    {
        "name"="interface.ethernet";
        "description"="";
        "version"="0.1.1";
    };
    {
        "name"="interface.list";
        "description"="";
        "version"="0.1.1";
    };
    {
        "name"="ip.address";
        "description"="";
        "version"="0.1.1";
    };
    {
        "name"="ip.firewall.address-list";
        "description"="";
        "version"="0.1.1";
    };
    {
        "name"="ip.route";
        "description"="";
        "version"="0.1.1";
    };
    {
        "name"="ip.route.rule";
        "description"="";
        "version"="0.1.1";
    };
    {
        "name"="rspm";
        "description"="rspm";
        "version"="0.1.1";
    };
    {
        "name"="rspm.reset";
        "description"="rspm configuration reset tools";
        "version"="0.1.1";
    };
    {
        "name"="rspm.state";
        "description"="rspm package state tools";
        "version"="0.1.1";
    };
    {
        "name"="tool.http";
        "description"="http utility";
        "version"="0.1.1";
    };
    {
        "name"="tool.json";
        "description"="json loads and dumps";
        "version"="0.1.1";
    };
    {
        "name"="tool.remote";
        "description"="remote script load tools";
        "version"="0.1.1";
    };
};

# core package meta mapping, use with list.
:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.array"=2;
    "global-functions.string"=3;
    "global-functions.cache"=4;
    "global-functions.datetime"=5;
    "global-functions.package"=6;
    "global-functions.unicode"=7;
    "global-functions.misc"=8;
    "global-helpers"=9;
    "interface.ethernet"=10;
    "interface.list"=11;
    "ip.address"=12;
    "ip.firewall.address-list"=13;
    "ip.route"=14;
    "ip.route.rule"=15;
    "rspm"=16;
    "rspm.reset"=17;
    "rspm.state"=18;
    "tool.http"=19;
    "tool.json"=20;
    "tool.remote"=21;
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
    "global-functions.unicode";
    "global-functions.misc";
    "tool.http";
    "tool.remote";
    "rspm.state";
    "rspm";
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
    "essentialPackageList"=$essentialPackageList;
}

:return $packageInfo;