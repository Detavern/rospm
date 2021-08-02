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
        "name"="rspm";
        "version"="0.0.1";
    };
};

:local packageMapping {
    "global-variables"=0;
    "global-functions"=1;
    "global-functions.package"=2;
    "global-helpers"=3;
    "tool.http"=4;
    "rspm"=5;
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
}

:return $packageInfo;
