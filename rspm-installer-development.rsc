:global RSPMInstallerConfig {
    "baseURL"="https://raw.githubusercontent.com/Detavern/rspm/development/";
    "owner"="rspm";
};
:global RSPMInstallerInput do={
    :terminal style escaped;
    :put $1; 
    :return;
}

# args: <str>           name of package
:local installPackage do={
    :global RSPMInstallerConfig;
    :global RSPMInstallerInput;
    :local pkgName $1;
    :local URL (($RSPMInstallerConfig->"baseURL") . "lib/" . $pkgName . ".rsc");
    :local Owner ($RSPMInstallerConfig->"owner");
    :put "Downloading file $pkgName...";
    :local result [/tool fetch url=$URL output="user" as-value];
    :local scriptStr ($result->"data");
    # check existance
    :local idList [/system script find name=$pkgName];
    :if ([:len $idList] != 0) do={
        :local scriptOwner [/system script get ($idList->0) owner];
        :if ($scriptOwner != ($RSPMInstallerConfig->"owner")) do={
            :put "Same script name \"$pkgName\" with owner \"$scriptOwner\" found in repository.";
            :local answer [$RSPMInstallerInput "Press y to replace it (y/N)"];
            :if ($answer != "y") do={
                :put "Abort";
                :return "";
            }
        }
        # remove exist one
        /system script remove numbers=$idList; 
    }
    # add script to repo
    :local scriptID [/system script add name=$pkgName owner=$Owner source=$scriptStr];
    :return $scriptID;
}

# installation
:put "-----------------------------------";
:put "| RouterOS Script Package Manager |";
:put "-----------------------------------";
:put "Installer initializing ...";
:local answer [$RSPMInstallerInput "WARNING: this is an DEVELOPMENT version, FOR DEVELOPER ONLY (y/N)"];
:if ($answer != "y") do={
    :put "Installation abort, use";
    :put "/import rspm-installer.rsc";
    :put "to run again.";
    :return "";
}

:local sidList [:toarray ""];
:set sidList ($sidList, [$installPackage "global-variables"]);
:set sidList ($sidList, [$installPackage "global-functions"]);
:set sidList ($sidList, [$installPackage "global-functions_array"]);
:set sidList ($sidList, [$installPackage "global-functions_string"]);
:set sidList ($sidList, [$installPackage "global-functions_cache"]);
:set sidList ($sidList, [$installPackage "global-functions_datetime"]);
:set sidList ($sidList, [$installPackage "global-functions_package"]);
:set sidList ($sidList, [$installPackage "global-functions_config"]);
:set sidList ($sidList, [$installPackage "global-functions_unicode"]);
:set sidList ($sidList, [$installPackage "global-functions_misc"]);

# load global
:foreach sid in $sidList do={
    :local cmdStr "/system script run number=$sid;";
    :local cmdFunc [:parse $cmdStr];
    [$cmdFunc ];
};

# install rspm
[$installPackage "tool_http"];
[$installPackage "tool_remote"];
[$installPackage "rspm_state"];
[$installPackage "rspm_reset"];
[$installPackage "rspm"];
# invoke rspm.firstRun to complete the installation
:global GetFunc;
[[$GetFunc "rspm.firstRun"] Context=$RSPMInstallerConfig];

# remove RSPM global envs
:local removeList [/system script environment find name~"RSPMInstaller"];
/system script environment remove numbers=$removeList;
:put "RSPM setup finished, enjoy!";
