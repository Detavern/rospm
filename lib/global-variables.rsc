# Global Variables
# =========================================================
# ALL global variables follows upper camel case.
#
# RUN this file first.
# USE as your wish

:local metaInfo {
    "name"="global-variables";
    "version"="0.1.1";
    "description"="global variable package";
    "global"=true;
};

# for framework
:global Nothing;
:global Nil [:find "" "" 1];
:global EmptyArray [:toarray ""];

:global TypeofNothing [:typeof $Nothing];

:global TypeofNil [:typeof $Nil];
:global TypeofStr [:typeof ""];
:global TypeofNum [:typeof 1];
:global TypeofBool [:typeof true];
:global TypeofID [:typeof *0];
:global TypeofTime [:typeof 00:00:00];
:global TypeofIP [:typeof 0.0.0.0];
:global TypeofIPPrefix [:typeof 0.0.0.0/0];
:global TypeofIPv6 [:typeof ::1];
:global TypeofIPv6Prefix [:typeof ::0/0];
:global TypeofArray [:typeof $EmptyArray];

# collect from system
:local sysInfo [/system resource print as-value]
:global SYSArchitectureName ($sysInfo->"architecture-name");
:global SYSBoardName ($sysInfo->"board-name");
:global SYSCPU ($sysInfo->"cpu");
:global SYSCPUCount ($sysInfo->"cpu-count");
:global SYSCPUFrequency ($sysInfo->"cpu-frequency");
:global SYSVersion ($sysInfo->"version");

# script limitation
:global ScriptLengthLimit 30000;
:global VariableLengthLimit 4096;

# datetime
:global MonthsOfTheYear {31;28;31;30;31;30;31;31;30;31;30;31};
:global MonthsName {"jan";"feb";"mar";"apr";"may";"jun";"jul";"aug";"sep";"oct";"nov";"dec"};

# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
