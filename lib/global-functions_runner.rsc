#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.template
# ===================================================================
# ALL global functions follows upper camel case.
# Global Package for template related operation
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.runner";
	"version"="0.7.0";
	"description"="Global Package for runner related operation";
	"global"=true;
	"global-functions"={
	};
};


# $BuildCommandParams
# Build command parameters by an array.
# args: <array->str>            params
# return: <str>                 params string
:global BuildCommandParams do={
	# global declare
	:global IsNil;
	:global IsStr;
	:global IsArray;
	# check
	:if (![$IsArray $1]) do={
		:error "Global.Runner.BuildCommandParams: \$1 should be an array."
	}
	# local
	:local cmdBody "";
	:foreach k,v in $1 do={
		:if (![$IsNil $v]) do={
			:if ([$IsStr $v]) do={
				:if ($v~"^!SUBS\\[.+\\]\$") do={
					:local vbody [:pick $v 6 ([:len $v]-1)];
					:set cmdBody ($cmdBody . " $k=\"\$[$vbody]\"");
				} else {
					:set cmdBody ($cmdBody . " $k=\"$v\"");
				}
			} else {
				:set cmdBody ($cmdBody . " $k=$v");
			}
		}
	}
	:return $cmdBody;
}


# $RunCommand
# args: <str>                   command
# args: <array->str>            params
# return: <obj>                 object
:global RunCommand do={
	# global declare
	:global IsNil;
    :global StartsWith;
	:global BuildCommandParams;
	# check
	:if (![$StartsWith $1 "/"]) do={
		:error "Global.Runner.RunCommand: \$1 should be a command."
	}
	# local
	:local cmdBody [$BuildCommandParams $2];
	:local cmdStr "$1 $cmdBody";
	# exec function
	:local cmdFunc [:parse $cmdStr];
	:local obj [$cmdFunc];
	:return $obj;
}


# $CreateEntity
# args: <str>                   command
# args: <array->str>            params
# return: <id>                  internal ID
:global CreateEntity do={
	# global declare
	:global IsNil;
    :global StartsWith;
	:global BuildCommandParams;
	# check
	:if (![$StartsWith $1 "/"]) do={
		:error "Global.Runner.CreateEntity: \$1 should be a command."
	}
	# local
	:local cmdBody [$BuildCommandParams $2];
	# exec function
	:local addFunc [:parse "$1/add $cmdBody"];
	:local iid [$addFunc];
	:return $iid;
}


# $EnableOrCreateEntity
# Find and enable an entity by a filter. Create one if not found.
# args: <str>                   command
# args: <array->str>            params
# opt args: <array->str>        filter
# return: <id>                  internal ID
:global EnableOrCreateEntity do={
	# global declare
	:global IsNil;
	:global IsNothing;
	:global IsEmpty;
	:global BuildCommandParams;
	# check
	:if (![$StartsWith $1 "/"]) do={
		:error "Global.Runner.EnableOrCreateEntity: \$1 should be a command."
	}
	:local cmdBody [$BuildCommandParams $2];
	:local filterBody $cmdBody;
	:if (![$IsNothing $3]) do={
		:set filterBody [$BuildCommandParams $3];
	}
	# local
	:local filterFunc [:parse "$1/find $filterBody"];
	:local idList [$filterFunc];
	:if ([$IsEmpty $idList]) do={
		# create
		:local addFunc [:parse "$1/add $cmdBody"];
		:local iid [$addFunc];
		:return $iid;
	} else {
		# enable if disabled
		:local enableFunc [:parse "$1/enable [find $filterBody disabled]"];
		[$enableFunc];
		:return ($idList->0);
	}
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
