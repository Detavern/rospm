#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.array
# ===================================================================
# ALL global functions follows upper camel case.
# Global functions are designed to perform array related operation.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.array";
	"version"="0.7.0.a";
	"description"="Global functions are designed to perform array related operation.";
	"global"=true;
	"global-functions"={
		"Insert";
		"Extend";
		"Reverse";
		"GetKeys";
		"IsSubset";
		"IsSuperset";
		"ArrayDiff";
	};
};


# $Insert
# Return a new array by inserting a variable to a numeric key array at a specific index.
# args: <array>                 source array
# args: <var>                   var to insert
# args: <num>                   insert position
# return: <array>               new array
:global Insert do={
	#DEFINE global
	:global NewArray;
	# local
	:local pre [$NewArray ];
	:local post [$NewArray ];
	:if ($3 > 0) do={
		:set pre [:pick $1 0 $3];
	}
	:if ($3 < [:len $1]) do={
		:set post [:pick $1 $3 [:len $1]];
	}
	:local a ($pre, 0, $post);
	:set ($a->[:tonum $3]) $2;
	:return $a;
}


# $Extend
# Return a new array by extending a numeric key array with another one at a specific index.
# args: <array>                 source array
# args: <array>                 array of var to extend at position
# args: <num>                   extend position
# return: <array>               new array
:global Extend do={
	#DEFINE global
	:global NewArray;
	:global TypeofNum;
	:global ReadOption;
	# local
	:local pos [$ReadOption $3 $TypeofNum [:len $1]];
	:local pre [$NewArray ];
	:local post [$NewArray ];
	:if ($pos > 0) do={
		:set pre [:pick $1 0 $pos];
	}
	:if ($pos < [:len $1]) do={
		:set post [:pick $1 $pos [:len $1]];
	}
	:local a ($pre, $2, $post);
	:return $a;
}


# $Reverse
# Return a new reversed array.
# args: <array>                 target array
# return: <array>               new array
:global Reverse do={
	#DEFINE global
	:global NewArray;
	# local
	:local result [$NewArray ];
	:for i from=([:len $1] - 1) to=0 step=-1 do={
		:set ($result->[:len $result]) ($1->$i);
	}
	:return $result;
}


# $GetKeys
# Return a new numeric key array by extracting the keys of an arbitrary array.
# args: <array>                 target array
# return: <array>               new array
:global GetKeys do={
	#DEFINE global
	:global NewArray;
	# local
	:local keys [$NewArray ];
	:foreach k,v in $1 do={
		:set ($keys->[:len $keys]) $k;
	}
	:return $keys;
}


# $IsSubset
# Return if a numeric key array A is subset of another numeric key array B.
# args: <array>                 array A
# args: <array>                 array B
# return: <bool>                flag
:global IsSubset do={
	#DEFINE global
	:global IsNil;
	:global NewArray;
	# local
	:if ([:len $1] > 0 and [:len $2] = 0) do={
		:return false;
	}
	:local m [$NewArray ];
	:foreach v in $2 do={
		:set ($m->$v) true;
	}
	:foreach v in $1 do={
		:if ([$IsNil ($m->$v)]) do={
			:return false;
		}
	}
	:return true;
}


# $IsSuperset
# Return if a numeric key array A is superset of another numeric key array B.
# args: <array>                 array A
# args: <array>                 array B
# return: <bool>                flag
:global IsSuperset do={
	#DEFINE global
	:global IsNil;
	:global NewArray;
	# local
	:if ([:len $2] > 0 and [:len $1] = 0) do={
		:return false;
	}
	:local m [$NewArray ];
	:foreach v in $1 do={
		:set ($m->$v) true;
	}
	:foreach v in $2 do={
		:if ([$IsNil ($m->$v)]) do={
			:return false;
		}
	}
	:return true;
}


# $ArrayDiff
# Return the difference between two k-v arrays.
# args: <array>                 array A
# args: <array>                 array B
# return: <array>               array A - B
:global ArrayDiff do={
	#DEFINE global
	:global IsNil;
	:global IsNothing;
	:global NewArray;
	# local
	:local diff [$NewArray ];
	:foreach k,v in $1 do={
		:if ([$IsNothing ($2->$k)]) do={
			:set ($diff->$k) $v;
		}
	}
	:return $diff;
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
