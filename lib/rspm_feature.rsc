#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   rspm.feature
# ===================================================================
# ALL package level functions follows lower camel case.
# rspm feature tools
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="rspm.feature";
    "version"="0.4.0";
    "description"="rspm feature tools";
};

# $globalCacheFuncOn
# turn on global cache for functions
:local globalCacheFuncOn do={
    # global declare
    :global GetConfig;
    :global UpdateConfig;
    :global LoadGlobalEnv;
    # env
    :global EnvGlobalCacheFuncEnabled;
    # local
    :local configName "config.rspm";
    # enable
    :if (!$EnvGlobalCacheFuncEnabled) do={
        # update config and reload
        :local config [$GetConfig $configName];
        :set (($config->"environment")->"GlobalCacheFuncEnabled") true;
        [$UpdateConfig $configName $config];
        [$LoadGlobalEnv $configName ($config->"environment")];
    }
}


# $globalCacheFuncOff
# turn off global cache for functions
:local globalCacheFuncOff do={
    # global declare
    :global GetConfig;
    :global UpdateConfig;
    :global LoadGlobalEnv;
    # env
    :global EnvGlobalCacheFuncEnabled;
    # local
    :local configName "config.rspm";
    # disable
    :if ($EnvGlobalCacheFuncEnabled) do={
        # update config and reload
        :local config [$GetConfig $configName];
        :set (($config->"environment")->"GlobalCacheFuncEnabled") false;
        [$UpdateConfig $configName $config];
        [$LoadGlobalEnv $configName ($config->"environment")];
        # flush cache
        [$GlobalCacheFuncFlush ];
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "globalCacheFuncOn"=$globalCacheFuncOn;
    "globalCacheFuncOff"=$globalCacheFuncOff;
}
:return $package
