# extension package meta list
:local packageList {
    {
        "name"="rspm.hello-world";
        "author"="rspm";
        "description"="";
        "version"="1.0.0";
        "url"="https://raw.githubusercontent.com/Detavern/rspm-pkg-hello-world/master/hello-world.rsc";
    };
};

# extension package meta mapping, use with list.
:local packageMapping {
    "rspm.hello-world"=0;
}

:local packageInfo {
    "packageList"=$packageList;
    "packageMapping"=$packageMapping;
}

:return $packageInfo;