# core package meta list
:local packageList {
    {
        "name"="global-variables";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-functions";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-functions.array";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-functions.string";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-functions.datetime";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-functions.package";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-functions.misc";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="global-helpers";
        "version"="0.1.0";
        "global"=true;
    };
    {
        "name"="tool.http";
        "version"="0.1.0";
    };
    {
        "name"="tool.remote";
        "version"="0.1.0";
    };
    {
        "name"="rspm.state";
        "version"="0.1.0";
    };
    {
        "name"="rspm";
        "version"="0.1.0";
    };
};

# core package meta mapping, use with list.
:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.array"=2;
    "global-functions.string"=3;
    "global-functions.datetime"=4;
    "global-functions.package"=5;
    "global-functions.misc"=6;
    "global-helpers"=7;
    "tool.http"=8;
    "tool.remote"=9;
    "rspm.state"=10;
    "rspm"=11;
}

# the minimum requirement packages of rspm
:local essentialPackageList {
    "global-variables";
    "global-functions";
    "global-functions.array";
    "global-functions.string";
    "global-functions.datetime";
    "global-functions.package";
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
