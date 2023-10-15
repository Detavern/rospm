# ROSPM uninstaller

:global IsNil;
:global ListAllGlobals;

:local owner "rospm";
:local sprefix "ROSPM_";
:local globals [$ListAllGlobals ];

# remove all schedulers
:put "Removing all schedulers ...";
/system/scheduler/remove [/system/scheduler/find name~$sprefix];

# remove all environments
:put "Removing all globals ...";
:foreach pkg in $globals do={
    /system/script/environment/remove [/system/script/environment/find name=$pkg];
}

# remove all scripts
:put "Removing all scripts ...";
/system/script/remove [/system/script/find owner=$owner];

