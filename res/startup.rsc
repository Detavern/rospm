# run framework
:log info "RSPM Startup: initializing...";
:local frameworkScriptList {
    "global-variables";
    "global-functions";
    "global-functions_array";
    "global-functions_string";
    "global-functions_cache";
    "global-functions_datetime";
    "global-functions_package";
    "global-functions_config";
    "global-functions_unicode";
    "global-functions_misc";
}

:foreach fileName in $frameworkScriptList do={
    :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
    :local cmdFunc [:parse $cmdStr];
    [$cmdFunc ];
}
:log info "RSPM Startup: framework loaded.";

# run the rest of global package
:global IsArrayN;
:global Replace;
:global GetConfig;
:global FindPackage;
:global LoadGlobalEnv;

:local configName "config.rspm";
:local configPkgName "config.rspm.package";
:local configExtPkgName "config.rspm.package.ext";
:local config [$GetConfig $configName];
:local configPkg [$GetConfig $configPkgName];
:local configExtPkg [$GetConfig $configExtPkgName];

# load env
:foreach meta in ($config->"configList") do={
    :local confName ($meta->"name");
    :local conf [$GetConfig $confName];
    :local env ($conf->"environment");
    :if ([$IsArrayN $env]) do={
        :do {
            [$LoadGlobalEnv $confName $env];
            :log info "RSPM Startup: configuration package $confName loaded.";
        } on-error={
            :log error "RSPM Startup: error occurred when loading package $confName, skipped.";
        }
    }
}

# load core
:foreach meta in ($configPkg->"packageList") do={
    :if ($meta->"global") do={
        :local pkgName ($meta->"name");
        :local pkgIDList [$FindPackage $pkgName];
        :if ([$IsArrayN $pkgIDList]) do={
            :local fileName [$Replace $pkgName "." "_"];
            :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
            :local cmdFunc [:parse $cmdStr];
            :do {
                [$cmdFunc ];
                :log info "RSPM Startup: global core package $pkgName loaded.";
            } on-error={
                :log error "RSPM Startup: error occurred when loading package $pkgName, skipped.";
            };
        }
    }
}

# load extension
:foreach meta in ($configExtPkg->"packageList") do={
    :if ($meta->"global") do={
        :local pkgName ($meta->"name");
        :local pkgIDList [$FindPackage $pkgName];
        :if ([$IsArrayN $pkgIDList]) do={
            :local fileName [$Replace $pkgName "." "_"];
            :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
            :local cmdFunc [:parse $cmdStr];
            :do {
                [$cmdFunc ];
                :log info "RSPM Startup: global core package $pkgName loaded.";
            } on-error={
                :log error "RSPM Startup: error occurred when loading package $pkgName, skipped.";
            };
        }
    }
}

:log info "RSPM Startup: all global package loaded, initialize finished.";