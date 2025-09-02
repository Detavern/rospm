:global ROSPMInstallerBaseURL "https://raw.githubusercontent.com/Detavern/rospm/master/";
:global ROSPMInstallerConfig {
    "ROSPMRepoName"="Detavern/rospm";
    "ROSPMBranch"="master";
    "ROSPMOwner"="rospm";
};
:global ROSPMInstallerInput do={
    :terminal style escaped;
    :put $1;
    :return;
}

# args: <str>           name of package
:local installPackage do={
    :global ROSPMInstallerBaseURL;
    :global ROSPMInstallerConfig;
    :global ROSPMInstallerInput;
    :local pkgName $1;
    :local URL ($ROSPMInstallerBaseURL . "lib/" . $pkgName . ".rsc");
    :local Owner ($ROSPMInstallerConfig->"ROSPMOwner");
    :put "Downloading file $pkgName...";
    :local result [/tool/fetch url=$URL output="user" as-value];
    :local scriptStr ($result->"data");
    # check existance
    :local idList [/system/script find name=$pkgName];
    :if ([:len $idList] != 0) do={
        :local scriptOwner [/system/script get ($idList->0) owner];
        :if ($scriptOwner != $Owner) do={
            :put "Same script name \"$pkgName\" with owner \"$scriptOwner\" found in repository.";
            :local answer [$ROSPMInstallerInput "Press y to replace it (y/N)"];
            :if ($answer != "y") do={
                :put "Abort";
                :return "";
            }
        }
        # remove exist one
        /system/script/remove numbers=$idList;
    }
    # add script to repo
    :local scriptID [/system/script/add name=$pkgName owner=$Owner source=$scriptStr];
    :return $scriptID;
}

# installation
:put "============================================================";
:put "|                                                          |";
:put "|    RRRRRR      OOOOO     SSSSSS   PPPPPP    MM    MM     |";
:put "|    RR   RR   OOO   OOO  SS        PP   PP   MMM  MMM     |";
:put "|    RRRRR    OOO     OOO  SSSSSS   PPPPPP   MM  MM  MM    |";
:put "|    RR   RR   OOO   OOO        SS  PP       MM      MM    |";
:put "|    RR    RR    OOOOO    SSSSSSS   PP      MM        MM   |";
:put "|                                                          |";
:put "============================================================";
:put "Installer initializing ...";
:local devMark "develop";
:if ([:pick ($ROSPMInstallerConfig->"ROSPMBranch") 0 [:len $devMark]] = $devMark) do={
    :local answer [$ROSPMInstallerInput "WARNING: this is a DEVELOPMENT version, FOR DEVELOPER ONLY (y/N)"];
    :if ($answer != "y" and $answer != "yes") do={
        :put "Installation abort, use";
        :put "/import rospm-installer.rsc";
        :put "to run again.";
        :return "";
    }
}

:local sidList [:toarray ""];
:set sidList ($sidList, [$installPackage "global-variables"]);
:set sidList ($sidList, [$installPackage "global-functions"]);
:set sidList ($sidList, [$installPackage "global-functions_array"]);
:set sidList ($sidList, [$installPackage "global-functions_string"]);
:set sidList ($sidList, [$installPackage "global-functions_network"]);
:set sidList ($sidList, [$installPackage "global-functions_random"]);
:set sidList ($sidList, [$installPackage "global-functions_datetime"]);
:set sidList ($sidList, [$installPackage "global-functions_package"]);
:set sidList ($sidList, [$installPackage "global-functions_config"]);
:set sidList ($sidList, [$installPackage "global-functions_runner"]);
:set sidList ($sidList, [$installPackage "global-functions_unicode"]);
:set sidList ($sidList, [$installPackage "global-functions_misc"]);

# load global
:foreach sid in $sidList do={
    :local cmdStr "/system/script run number=$sid;";
    :local cmdFunc [:parse $cmdStr];
    [$cmdFunc ];
};

# install rospm
[$installPackage "tool_http"];
[$installPackage "tool_remote"];
[$installPackage "rospm_config"];
[$installPackage "rospm_state"];
[$installPackage "rospm_action"];
[$installPackage "rospm_reset"];
[$installPackage "rospm"];
# invoke rospm.firstRun to complete the installation
:global GetFunc;
[[$GetFunc "rospm.firstRun"] Context=$ROSPMInstallerConfig];

# remove ROSPM global envs
:local removeList [/system/script/environment/find name~"ROSPMInstaller"];
/system/script/environment/remove numbers=$removeList;
:put "ROSPM setup finished, enjoy!";
