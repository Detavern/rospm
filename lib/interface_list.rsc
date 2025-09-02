#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   interface.list
# ===================================================================
# ALL package level functions follows lower camel case.
# interface list related functions.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="interface.list";
	"version"="0.6.0";
	"description"="interface list related functions.";
};


# $ensure
# kwargs: Name=<str>            ensure a list name is exist
:local ensure do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global GetOrCreateEntity;
	# check params
	:if (![$IsStr $Name]) do={
		:error "interface.list.ensure: require \$Name";
	}
	# local
	:return [$GetOrCreateEntity "/interface/list" ({"name"=$Name})];
}


# $ensureInclude
# ensure target list's include list
# kwargs: Name=<str>                target list name
# kwargs: List=<array->str>         list of included list name
:local ensureInclude do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global IsArray;
	:global IsEmpty;
	:global Extend;
	:global UniqueArray;
	# check params
	:if (![$IsStr $Name]) do={
		:error "interface.list.ensureInclude: require \$Name";
	}
	:if (![$IsArray $List]) do={
		:error "interface.list.ensureInclude: require \$List";
	}
	# check list's existance
	:local idList [/interface/list/find name=$Name];
	:if ([$IsEmpty $idList]) do={
		:error "interface.list.ensureInclude: interface list name $Name not found";
	}
	:foreach v in $List do={
		:local vIDList [/interface/list/find name=$v];
		:if ([$IsEmpty $vIDList]) do={
			:error "interface.list.ensureInclude: interface list name $v in \$List not found";
		}
	}
	# get current include
	:local srcIncludeList [/interface/list/get number=$idList "include"];
	:local mergedList [$UniqueArray [$Extend $srcIncludeList $List]];
	# set it
	/interface/list/set $Name include=$mergedList;
}


# $ensureExclude
# ensure target list's exclude list
# kwargs: Name=<str>                target list name
# kwargs: List=<array->str>         list of excluded list name
:local ensureExclude do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global IsArray;
	:global IsEmpty;
	:global Extend;
	:global UniqueArray;
	# check params
	:if (![$IsStr $Name]) do={
		:error "interface.list.ensureExclude: require \$Name";
	}
	:if (![$IsArray $List]) do={
		:error "interface.list.ensureExclude: require \$List";
	}
	# check list's existance
	:local idList [/interface/list/find name=$Name];
	:if ([$IsEmpty $idList]) do={
		:error "interface.list.ensureExclude: interface list name $Name not found";
	}
	:foreach v in $List do={
		:local vIDList [/interface/list/find name=$v];
		:if ([$IsEmpty $vIDList]) do={
			:error "interface.list.ensureExclude: interface list name $v in \$List not found";
		}
	}
	# get current include
	:local srcExcludeList [/interface/list/get number=$itemID "include"];
	:local mergedList [$UniqueArray [$Extend $srcExcludeList $List]];
	# set it
	/interface/list/set $Name include=$mergedList;
}


# $ensureMembers
# kwargs: List=<str>                target list
# kwargs: Interfaces=<array->str>   list of interface name
:local ensureMembers do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global IsArray;
	:global IsEmpty;
	:global GetOrCreateEntity;
	# check params
	:if (![$IsStr $List]) do={
		:error "interface.list.ensureMembers: require \$List";
	}
	:if (![$IsArray $Interfaces]) do={
		:error "interface.list.ensureMembers: require \$Interfaces";
	}
	# check list's existance
	:local idList [/interface/list/find name=$List];
	:if ([$IsEmpty $idList]) do={
		:error "interface.list.ensureMembers: interface list name $List not found";
	}
	:foreach v in $Interfaces do={
		:local vidList [/interface/find name=$v !dynamic];
		:if ([$IsEmpty $vidList]) do={
			:error "interface.list.ensureMembers: static interface name $v not found";
		}
	}
	# ensure membership
	:foreach v in $Interfaces do={
		[$GetOrCreateEntity "/interface/list/member" \
			({"list"=$List;"interface"=$v}) Disabled=false];
	}
}


# $findMembers
# find all interface by list name
# kwargs: List=<str>            target list
# opt kwargs: Disabled=<bool>   false(default), find disabled interface if true
:local findMembers do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global IsEmpty;
	:global TypeofBool;
	:global ReadOption;
	:global UniqueArray;
	:global FindEntities;
	# local
	:local disabledFlag [$ReadOption $Disabled $TypeofBool false];
	# check
	:if (![$IsStr $Name]) do={
		:error "interface.list.findMembers: require \$Name";
	}
	:local intfIDList [/interface/list/find name=$Name !disabled];
	:if ([$IsEmpty $intfIDList]) do={
		:error "interface.list.findMembers: specific \$Name not exist or disabled"
	}
	# get name list
	:local template ({"list"=$Name; "!disabled"=!$disabledFlag});
	:local nameList [$FindEntities "/interface/list/member" \
		$template Attribute="interface"];
	# find in include
	:local includeList [/interface/list/get ($intfIDList->0) include];
	:foreach listName in $includeList do={
		:set ($template->"list") $listName;
		:local nList [$FindEntities "/interface/list/member" \
			$template Attribute="interface"];
		:set nameList ($nameList, $nList);
	}
	:return [$UniqueArray $nameList];
}


:local package {
	"metaInfo"=$metaInfo;
	"add"=$add;
	"ensure"=$ensure;
	"getInclude"=$getInclude;
	"ensureInclude"=$ensureInclude;
	"ensureExclude"=$ensureExclude;
	"ensureMembers"=$ensureMembers;
	"findMembers"=$findMembers;
}
:return $package;
