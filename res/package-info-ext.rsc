:local packageList {
    {
        "name"="rspm.hello-world";
        "version"="1.0.0";
        "author"="rspm";
        "url"="https://raw.githubusercontent.com/Detavern/rspm-pkg-hello-world/master/hello-world.rsc";
    };
};

:local packageMapping {
    "rspm.hello-world"=0;
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
}

:return $packageInfo;
