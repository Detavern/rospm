:global RSPMInstallerConfig {
    "BaseURL"="https://raw.githubusercontent.com/Detavern/rspm/master/";
    "Owner"="rspm";
};
:global RSPMInput do={
    :terminal style escaped;
    :put $1; 
    :return;
}

# args: <str>           name of package
:local installPackage do={
    :global RSPMInstallerConfig;
    :global RSPMInput;
    :local pkgName $1;
    :local URL (($RSPMInstallerConfig->"BaseURL") . "lib/" . $pkgName . ".rsc");
    :local Owner ($RSPMInstallerConfig->"Owner");
    :put "Downloading file $pkgName...";
    :local result [/tool fetch url=$URL output="user" as-value];
    :local scriptStr ($result->"data");
    # check existance
    :local idList [/system script find name=$pkgName];
    :if ([:len $idList] != 0) do={
        :local scriptOwner [/system script get ($idList->0) owner];
        :if ($scriptOwner != ($RSPMInstallerConfig->"Owner")) do={
            :put "Same script name \"$pkgName\" with owner \"$scriptOwner\" found in repository.";
            :local answer [$RSPMInput "Press y to replace it (y/N)"];
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
:local answer [$RSPMInput "WARNING: this is a PROTOTYPE version, FOR TEST ONLY (y/N)"];
:if ($answer != "y") do={
    :put "Installation abort, use";
    :put "/import rspm-installer.rsc";
    :put "to run again.";
    :return "";
}

:local sidList [:toarray ""];
:set sidList ($sidList, [$installPackage "global-variables"]);
:set sidList ($sidList, [$installPackage "global-functions"]);
:set sidList ($sidList, [$installPackage "global-functions_package"]);

# load global
:foreach sid in $sidList do={
    :local cmdStr "/system script run number=$sid;";
    :local cmdFunc [:parse $cmdStr];
    [$cmdFunc ];
};

# install rspm
[$installPackage "tool_http"];
[$installPackage "rspm"];
# invoke rspm.firstRun to complete the installation
:global GetFunc;
[[$GetFunc "rspm.firstRun"] Context=$RSPMInstallerConfig];

# remove RSPM global envs
:local removeList [/system script environment find name~"RSPM"];
/system script environment remove numbers=$removeList;
:put "RSPM setup finished, enjoy!";