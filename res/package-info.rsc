# core package meta list
:local packageList {
    {
        "name"="global-variables";
        "version"="0.0.1";
        "global"=true;
    };
    {
        "name"="global-functions";
        "version"="0.0.1";
        "global"=true;
    };
    {
        "name"="global-functions.datetime";
        "version"="0.0.1";
        "global"=true;
    };
    {
        "name"="global-functions.package";
        "version"="0.0.1";
        "global"=true;
    };
    {
        "name"="global-helpers";
        "version"="0.0.1";
        "global"=true;
    };
    {
        "name"="tool.http";
        "version"="0.0.1";
    };
    {
        "name"="tool.remote";
        "version"="0.0.1";
    };
    {
        "name"="rspm.state";
        "version"="0.0.1";
    };
    {
        "name"="rspm";
        "version"="0.0.1";
    };
};

# core package meta mapping, use with list.
:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.datetime"=2;
    "global-functions.package"=3;
    "global-helpers"=4;
    "tool.http"=5;
    "tool.remote"=6;
    "rspm.state"=7;
    "rspm"=8;
}

# the minimum requirement packages of rspm
:local essentialPackageList {
    "global-variables";
    "global-functions";
    "global-functions.datetime";
    "global-functions.package";
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
