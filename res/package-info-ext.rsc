# extension package meta list
:local packageList {
    {
        "name"="global-variables";
        "description"="global variable package";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-functions";
        "description"="global function package";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-functions.array";
        "description"="global functions for array related operation";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-functions.string";
        "description"="global functions for string related operation";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-functions.datetime";
        "description"="global functions for datetime operation";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-functions.package";
        "description"="global functions for package operation";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-functions.misc";
        "description"="global functions for miscellaneous collection";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="global-helpers";
        "description"="global helper package";
        "version"="0.1.0";
        "url"="";
        "global"=true;
    };
    {
        "name"="interface.ethernet";
        "description"="";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="interface.list";
        "description"="";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="ip.address";
        "description"="";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="ip.firewall.address-list";
        "description"="";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="ip.route";
        "description"="";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="ip.route.rule";
        "description"="";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="rspm";
        "description"="rspm";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="rspm.reset";
        "description"="rspm configuration reset tools";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="rspm.state";
        "description"="rspm package state tools";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="tool.http";
        "description"="http utility";
        "version"="0.1.0";
        "url"="";
    };
    {
        "name"="tool.remote";
        "description"="remote script load tools";
        "version"="0.1.0";
        "url"="";
    };
};

# extension package meta mapping, use with list.
:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.array"=2;
    "global-functions.string"=3;
    "global-functions.datetime"=4;
    "global-functions.package"=5;
    "global-functions.misc"=6;
    "global-helpers"=7;
    "interface.ethernet"=8;
    "interface.list"=9;
    "ip.address"=10;
    "ip.firewall.address-list"=11;
    "ip.route"=12;
    "ip.route.rule"=13;
    "rspm"=14;
    "rspm.reset"=15;
    "rspm.state"=16;
    "tool.http"=17;
    "tool.remote"=18;
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
}

:return $packageInfo;