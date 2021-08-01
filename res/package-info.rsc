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
        "name"="hello-world";
        "version"="0.0.1";
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
    "hello-world"=4;
    "tool.http"=5;
    "rspm"=6;
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
}

:return $packageInfo;
