#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions
# ===================================================================
# ALL global functions follows upper camel case.
# This package provides global functions for type checking, input, and array operations in ROSPM.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions";
	"version"="0.7.0";
	"description"="This package provides global functions for type checking, input, and array operations in ROSPM.";
	"global"=true;
	"global-functions"={
		"IsNil";
		"IsNothing";
		"IsNum";
		"IsStr";
		"IsBool";
		"IsTime";
		"IsArray";
		"IsIP";
		"IsIPv6";
		"IsIPPrefix";
		"IsIPv6Prefix";
		"IsEmpty";
		"IsStrN";
		"IsArrayN";
		"IsDict";
		"NewArray";
		"Assert";
		"Print";
		"PrintK";
		"GetGlobal";
		"TypeRecovery";
		"ReadOption";
		"InKeys";
		"InValues";
		"Input";
		"InputV";
	};
};

# $IsNil
# Validate if the variable is nil.
# Some example of nil situation:
# {
#     :local v;
#     :set v [:find "" "" 1];
#     :put ([$IsNil $1]);
# }
# TODO: ADD MORE HERE
# args: <var>                   variable
:global IsNil do={
	:global TypeofNil;
	:if ([:typeof $1] = $TypeofNil) do={
		return true;
	} else {
		return false;
	}
}


# $IsNothing
# Validate if the variable is nothing.
# Some example of nothing situation:
# {
#     :local v;
#     :put [$IsNothing $1];
# }
# {
#     :local a {"k"="v"};
#     :put [$IsNothing ($a->"notexist")];
# }
# TODO: ADD MORE HERE
# args: <var>                   variable
:global IsNothing do={
	:global TypeofNothing;
	:if ([:typeof $1] = $TypeofNothing) do={
		return true;
	} else {
		return false;
	}
}


# $IsNum
# Validate the type of variable.
# args: <var>                   variable
:global IsNum do={
	:global TypeofNum;
	:if ([:typeof $1] = $TypeofNum) do={
		return true;
	} else {
		return false;
	}
}


# $IsStr
# Validate the type of variable.
# args: <var>                   variable
:global IsStr do={
	:global TypeofStr;
	:if ([:typeof $1] = $TypeofStr) do={
		return true;
	} else {
		return false;
	}
}


# $IsBool
# Validate the type of variable.
# args: <var>                   variable
:global IsBool do={
	:global TypeofBool;
	:if ([:typeof $1] = $TypeofBool) do={
		return true;
	} else {
		return false;
	}
}


# $IsTime
# Validate the type of variable.
# args: <var>                   variable
:global IsTime do={
	:global TypeofTime;
	:if ([:typeof $1] = $TypeofTime) do={
		return true;
	} else {
		return false;
	}
}


# $IsArray
# Validate the type of variable.
# args: <var>                   variable
:global IsArray do={
	:global TypeofArray;
	:if ([:typeof $1] = $TypeofArray) do={
		return true;
	} else {
		return false;
	}
}


# $IsIP
# Validate the type of variable.
# args: <var>                   variable
:global IsIP do={
	:global TypeofIP;
	:if ([:typeof $1] = $TypeofIP) do={
		return true;
	} else {
		return false;
	}
}


# $IsIPv6
# Validate the type of variable.
# args: <var>                   variable
:global IsIPv6 do={
	:global TypeofIPv6;
	:if ([:typeof $1] = $TypeofIPv6) do={
		return true;
	} else {
		return false;
	}
}


# $IsIPPrefix
# Validate the type of variable.
# args: <var>                   variable
:global IsIPPrefix do={
	:global TypeofIPPrefix;
	:if ([:typeof $1] = $TypeofIPPrefix) do={
		return true;
	} else {
		return false;
	}
}


# $IsIPv6Prefix
# Validate the type of variable.
# args: <var>                   variable
:global IsIPv6Prefix do={
	:global TypeofIPv6Prefix;
	:if ([:typeof $1] = $TypeofIPv6Prefix) do={
		return true;
	} else {
		return false;
	}
}


# $IsEmpty
# Validate if $1 is an array and is empty.
# if $1 is not an array, then raise error.
# if $1 is empty, return false.
# args: <array>                 array
:global IsEmpty do={
	:global IsArray;
	:if ([$IsArray $1]) do={
		:if ([:len $1]=0) do={
			:return true;
		}
		:return false;
	}
	:error "Global.IsEmpty: \$1 shoud be an array";
}


# $IsStrN
# Validate if $1 is a str and not empty.
# else, return false.
# args: <var>                   variable
:global IsStrN do={
	:global IsStr;
	:if ([$IsStr $1]) do={
		:if ([:len $1] > 0) do={
			:return true;
		}
	}
	:return false;
}


# $IsArrayN
# Validate if $1 is an array and not empty.
# else, return false.
# args: <var>                   variable
:global IsArrayN do={
	:global IsArray;
	:if ([$IsArray $1]) do={
		:if ([:len $1] > 0) do={
			:return true;
		}
	}
	:return false;
}


# $IsDict
# Validate if an array is a dictionary(contain any key which type is string).
# args: <array>                 array
:global IsDict do={
	:global IsNum;
	:global IsEmpty;
	:if ([$IsEmpty $1]) do={
		:error "Global.IsDict: empty array";
	}
	:foreach k,v in $1 do={
		:if (![$IsNum $k]) do={
			:return true;
		}
	}
	:return false;
}


# $NewArray
# Get a new empty array.
# return: <array>               <empty array>
:global NewArray do={
	:return [:toarray ""]
}


# $Assert
# Assert the condition, print error message if false.
# args: <bool>                  condition
# args: <str>                   error message
:global Assert do={
	:if ($1=false) do={
		:error "Assert error: $2";
	}
}


# $Print
# Print the type and value of the variable.
# TODO: embbed array
# args: <var>                   variable
:global Print do={
	# global declare
	:global IsArray;
	:global IsEmpty;
	# put type first
	:put ("Type  : " . [:typeof $1]);
	:local vStr "Value : ";
	# unpack if array
	:if ([$IsArray $1]) do={
		:foreach k,v in $1 do={
			:put ("Key $k: " . [:tostr $v]);
		}
		:if ([$IsEmpty $1]) do={
			:put "Empty Array"
		}
	} else {
		:put ("Value : " . [:tostr $1]);
	}
}


# $PrintK
# Print the keys of an array.
# args: <array>                 array
:global PrintK do={
	# global declare
	:global IsArray;
	# check
	:if ([$IsArray $1]) do={
		:put ("Length: " . [:len $1]);
		:foreach k,v in $1 do={
			:put ("Key $k: ");
		}
		:if ([$IsEmpty $1]) do={
			:put "Empty Array"
		}
	} else {
		:error ("Global.PrintK: need an array")
	}
}


# $GetGlobal
# Get global variable's value by its name.
# args: <name>                  name
:global GetGlobal do={
	:local cmd ":global $1;:return \$$1";
	:local cmdFunc [:parse $cmd];
	:local gVar [$cmdFunc];
	:return $gVar;
}


# $TypeRecovery
# Recover type and value from a string.
# args: <str>                   value to recover
# return: <var>                 recovered value
:global TypeRecovery do={
	:local value;
	:if ([:len $1] = 0) do={
		:error "Global.TypeRecovery: no value";
	}
	:do {
		:local cmdStr "{:local rT do={:return \$1}; :local v $1; \$rT \$v;}";
		:local cmdFunc [:parse $cmdStr];
		:set value [$cmdFunc ];
	} on-error={
		:set value $1;
	}
	:return $value;
}


# $ReadOption
# Read and validate the input, could set default value.
# Nil value is not allowed as input. If nothing and no default, return nil.
# args: <var>                   <value>
# args: <var>                   typeof <value>
# opt args: <var>               default value of $1
# return: <var>                 <value or default>
:global ReadOption do={
	# global declare
	:global Nil;
	:global IsNothing;
	:global IsNil;
	:global IsStr;
	:global TypeRecovery;
	:global TypeofBool;
	:global TypeofNum;
	:global TypeofID;
	:global TypeofTime;
	:global TypeofIP;
	:global TypeofIPv6;
	:global TypeofArray;
	# local
	:local default;
	# check default value type match
	:if (![$IsNothing $3]) do={
		:if ([:typeof $3]=$2) do={
			:set default $3;
		} else {
			:if ([$IsStr $3]) do={
				:set default [$TypeRecovery $3];
				:if ([:typeof $default]!=$2) do={
					:error "Global.ReadOption: type of \$default should match \$Typeof";
				}
			} else {
				:local hint ("<type>: " . [:typeof $3] . " <value>: $3");
				:error "Global.ReadOption: type of \$default should match \$Typeof, $hint";
			}
		}
	}
	# nothing, no default, return nil
	# nothing, has default, return default
	:if ([$IsNothing $1]) do={
		:if ([$IsNothing $default]) do={
			:return $Nil;
		} else {
			:return $default;
		}
	}
	:if ([$IsNil $1]) do={
		:error "Global.ReadOption: get nil value";
	}
	# type specific
	:if ($2 = $TypeofBool) do={
		:if ($1 = "false" or $1 = "no") do={
			:return false;
		};
		:if ($1 = "true" or $1 = "yes") do={
			:return true;
		}
		:local b [:tobool $1];
		:if ([$IsNil $b]) do={
			:error "Global.ReadOption: target bool, get nil value";
		} else {
			:return $b;
		}
	}
	:if ($2 = $TypeofNum) do={
		:return [:tonum $1];
	}
	:if ($2 = $TypeofID) do={
		:return [:toid $1];
	}
	:if ($2 = $TypeofTime) do={
		:return [:totime $1];
	}
	:if ($2 = $TypeofIP) do={
		:return [:toip $1];
	}
	:if ($2 = $TypeofIPv6) do={
		:return [:toip6 $1];
	}
	:if ($2 = $TypeofArray) do={
		:if ([:typeof $1] != $TypeofArray) do={
			:error "Global.ReadOption: \$1 should be an array";
		}
	}
	# default return
	:return $1;
}


# $InKeys
# Check if an element exists in the keys of an array.
# args: <var>                   key to seach
# args: <array->var>            array to search in
# return: <bool>                in or not
:global InKeys do={
	:foreach k,v in $2 do={
		:if ($k=$1) do={
			:return true;
		}
	}
	:return false;
}


# $InValues
# Check if an element exists in the values of an array.
# args: <var>                   value to seach
# args: <array->var>            array to search in
# return: <bool>                in or not
:global InValues do={
	:foreach k,v in $2 do={
		:if ($v=$1) do={
			:return true;
		}
	}
	:return false;
}


# $Input
# Get value from interaction.
# args: <str>                   hint
# return: <var>                 value
:global Input do={
	:terminal style escaped;
	:put $1;
	:return;
}


# $InputV
# Get value from interaction and recover its type and value.
# If input is empty and default is not setted, error will be raised.
# If input is empty and default is a nil value, nil will be returned.
# args: <str>                   hint
# opt kwargs: Default=<var>     default value
# return: <var>                 recovered input value
:global InputV do={
	# global declare
	:global Nil;
	:global IsNothing;
	:global IsStr;
	:global Input;
	:global TypeRecovery;
	# local
	:if (![$IsStr $1]) do={
		:error "Global.InputV: hint should be str";
	}
	:local hint $1;
	:local valueStr;
	# no default value
	:if ([$IsNothing $Default]) do={
		# no default value
		:set valueStr [$Input $hint];
		:if ([:len $valueStr] = 0) do={
			:error "Global.InputV: input needed";
		}
		:return [$TypeRecovery $valueStr];
	}
	# has default value
	:local defaultStr $Default;
	:if ([:len $Default] = 0) do={
		:set defaultStr "\$Nil";
	}
	:set valueStr [$Input ("$hint (Default: $defaultStr)")];
	:if ([:len $valueStr] = 0) do={
		:if ([:len $Default] = 0) do={
			:return $Nil;
		}
		:return [$TypeRecovery $Default];
	}
	:return [$TypeRecovery $valueStr];
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
