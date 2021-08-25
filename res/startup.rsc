# run framework
:log info "RSPM Startup: initializing...";
:local frameworkScriptList {
    "global-variables";
    "global-functions";
    "global-functions_array";
    "global-functions_string";
    "global-functions_datetime";
    "global-functions_package";
    "global-functions_misc";
}

:foreach fileName in $frameworkScriptList do={
    :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
    :local cmdFunc [:parse $cmdStr];
    [$cmdFunc ];
}
:log info "RSPM Startup: framework loaded.";

# run the rest of global package
:global Print;
:global IsEmpty;
:global Replace;
:global GetFunc;
:global GetConfig;
:global FindPackage;

:local configPkgName "config.rspm.package";
:local configExtPkgName "config.rspm.package.ext";
:local config [$GetConfig $configPkgName];
:local configExt [$GetConfig $configExtPkgName];

# load core
:foreach meta in ($config->"packageList") do={
    :if ($meta->"global") do={
        :local pkgName ($meta->"name");
        :local pkgIDList [$FindPackage $pkgName];
        :if (![$IsEmpty $pkgIDList]) do={
            :local fileName [$Replace $pkgName "." "_"];
            :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
            :local cmdFunc [:parse $cmdStr];
            :do {
                [$cmdFunc ];
                :log info "RSPM Startup: global core package $pkgName loaded.";
            } on-error {
                :log error "RSPM Startup: error occurred when loading package $pkgName, skipped.";
            };
        }
    }
}

# load extension
:foreach meta in ($configExt->"packageList") do={
    :if ($meta->"global") do={
        :local pkgName ($meta->"name");
        :local pkgIDList [$FindPackage $pkgName];
        :if (![$IsEmpty $pkgIDList]) do={
            :local fileName [$Replace $pkgName "." "_"];
            :local cmdStr "/system script run [/system script find name=\"$fileName\"];";
            :local cmdFunc [:parse $cmdStr];
            :do {
                [$cmdFunc ];
                :log info "RSPM Startup: global core package $pkgName loaded.";
            } on-error {
                :log error "RSPM Startup: error occurred when loading package $pkgName, skipped.";
            };
        }
    }
}

:log info "RSPM Startup: all global package loaded, initialize finished.";