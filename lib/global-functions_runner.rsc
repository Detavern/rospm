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
	:global IsNothing;
	:global IsStr;
	:global IsBool;
	:global IsArray;
	# check
	:if (![$IsArray $1]) do={
		:error "Global.Runner.BuildCommandParams: \$1 should be an array."
	}
	# local
	:local cmdBody "";
	:local disabledFlag;
	:local makePair do={
		:global IsNil;
		:global IsNothing;
		:global IsNum;
		:global IsStr;
		# invalid
		:if ([$IsNil $Value] or [$IsNothing $Value] or [$IsNum $Key]) do={
			:return "";
		}
		# ignored
		:if ($Key = "disabled") do={
			:return "";
		}
		# escaped
		:if ($Value~"^!SUBS\\[.+\\]\$") do={
			:local vbody [:pick $Value 6 ([:len $Value]-1)];
			:return " $Key=\"\$[$vbody]\"";
		}
		# string
		:if ([$IsStr $Value]) do={
			:return " $Key=\"$Value\"";
		}
		:return " $k=$v";
	}
	:foreach k,v in $1 do={
		:local paramStr [$makePair Key=$k Value=$v];
		:set cmdBody ($cmdBody . $paramStr);
		:if ($k = "disabled" and [$IsBool $v]) do={
			:set disabledFlag $v;
		}
	}
	# append disabled flag
	:if (![$IsNothing $disabledFlag]) do={
		:if ($disabledFlag) do={
			:set cmdBody ($cmdBody . " disabled");
		} else {
			:set cmdBody ($cmdBody . " !disabled");
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


# $ListAttributes
# List attributes of a list of internal id.
# args: <str>               command
# args: <array->id>         array of id
# opt args: <str>           attribute name
:global ListAttributes do={
	# global declare
	:global IsNil;
	:global IsNothing;
	:global IsArray;
	:global StartsWith;
	:global NewArray;
	# check
	:if (![$StartsWith $1 "/"]) do={
		:error "Global.Runner.ListAttributes: \$1 should be a command."
	}
	:if (![$IsArray $2]) do={
		:error "Global.Runner.ListAttributes: \$2 should be an array of id."
	}
	:local attr "";
	:if (![$IsNothing $3]) do={
		:set attr $3;
	}
	# local
	:local result [$NewArray];
	:foreach iid in $2 do={
		:local cmdFunc [:parse "$1/get $iid $attr"];
		:local v [$cmdFunc];
		:set ($result->[:len $result]) $v;
	}
	:return $result;
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


# $FindEntities
# Find entities by a filter and return an array
# args: <str>                   command
# args: <array->str>            filter
# opt kwargs: Attribute=<str>   attribute name
:global FindEntities do={
	# global declare
	:global IsNil;
	:global IsStr;
	:global IsBool;
	:global TypeofStr;
	:global ReadOption;
	:global StartsWith;
	:global BuildCommandParams;
	:global ListAttributes;
	# check
	:if (![$StartsWith $1 "/"]) do={
		:error "Global.Runner.FindEntities: \$1 should be a command."
	}
	:local filterBody [$BuildCommandParams $2];
	# local
	:local attr [$ReadOption $Attribute $TypeofStr];
	:local cmdFunc [:parse "$1/find $filterBody"];
	:local idList [$cmdFunc];
	:if ([$IsNil $attr]) do={
		:return $idList;
	}
	# attribute present
	:local attrList [$ListAttributes $1 $idList $attr];
	:return $attrList;
}


# $GetOrCreateEntity
# Find an entity by a filter. Create one if not found.
# args: <str>                       command
# args: <array->str>                params
# opt kwargs: Filter=<array->str>   filter
# opt kwargs: Disabled=<array->str> disabled flag
# return: <id>                      internal ID
:global GetOrCreateEntity do={
	# global declare
	:global IsNil;
	:global IsNothing;
	:global IsEmpty;
	:global TypeofBool;
	:global ReadOption;
	:global StartsWith;
	:global BuildCommandParams;
	# check
	:if (![$StartsWith $1 "/"]) do={
		:error "Global.Runner.GetOrCreateEntity: \$1 should be a command."
	}
	:local cmdBody [$BuildCommandParams $2];
	:local filterBody $cmdBody;
	:if (![$IsNothing $Filter]) do={
		:set filterBody [$BuildCommandParams $Filter];
	}
	# local
	:local disabledFlag [$ReadOption $Disabled $TypeofBool];
	:local filterFunc [:parse "$1/find $filterBody"];
	:local idList [$filterFunc];
	# create if not found
	:if ([$IsEmpty $idList]) do={
		:local addFunc [:parse "$1/add $cmdBody"];
		:local iid [$addFunc];
		:return $iid;
	}
	# flag present
	:if (![$IsNil $disabledFlag]) do={
		:if ($disabledFlag) do={
			# disable if disabled
			:local disableFunc [:parse "$1/disable [find $filterBody !disabled]"];
			[$disableFunc];
		} else {
			:local enableFunc [:parse "$1/enable [find $filterBody disabled]"];
			[$enableFunc];
		}
	}
	:return ($idList->0);
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
