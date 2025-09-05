#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.package
# ===================================================================
# ALL global functions follows upper camel case.
# Global functions are vital for the package operation.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.package";
	"version"="0.7.0.a";
	"description"="Global functions are vital for the package operation.";
	"global"=true;
	"global-functions"={
		"FindPackage";
		"ValidateMetaInfo";
		"GetSource";
		"GetMeta";
		"ParseMetaSafe";
		"GetMetaSafe";
		"GetEnv";
		"PrintPackageInfo";
		"LoadPackage";
		"GetFunc";
		"DumpVar";
		"LoadVar";
		"SetGlobalVar";
		"LoadGlobalVar";
		"UnsetGlobalVar";
		"CompareVersion";
	};
};


# $FindPackage
# args: <str>                   <package name>
# return: <id> or nil           id of package in /system script
:global FindPackage do={
	#DEFINE global
	:global IsNil;
	:global Replace;
	# replace
	:local pkgName $1;
	:local fileName [$Replace $pkgName "." "_"];
	:local idList [/system/script/find name=$fileName];
	:return $idList;
}


# $ValidateMetaInfo
# Validate the meta info by a validate array, return a specific result contains flag & reason.
# va example:
# {
#     "name"=<target package name>;
#     "type"=<choice: code,config,env>;
#     "ext"=<bool>;
#     "local"=<bool>;
#     "extl"=<bool>;
# }
# result example:
# {
#     "flag"=<bool>;
#     "reasons"={"reason1";"reason2"};
# }
# args: <array->str>                package content array
# args: <array->str>(<va>)          validate array
# return: <array->str>(<result>)    validate result
:global ValidateMetaInfo do={
	:global IsNil;
	:global InKeys;
	:global IsArray;
	:global ReadOption;
	:global TypeofStr;
	:global TypeofBool;
	:global NewArray;
	:global StartsWith;
	# check validate array
	:local va $2;
	:if (![$IsArray $va]) do={
		:error "Global.Package.ValidateMetaInfo: \$2 should be a validate array.";
	}
	# prepare result
	:local res {
		"flag"=false;
		"reasons"=[$NewArray ];
	}
	# check meta
	:local metaList $1;
	:if (![$IsArray $metaList]) do={
		:set (($res->"reasons")->[:len ($res->"reasons")]) "metaInfo not found in this package";
		:return $res;
	}

	:local metaName ($metaList->"name");
	# va: check meta name
	:if ([$InKeys "name" $va]) do={
		:local vat ($va->"name");
		:if ($metaName != $vat) do={
			:set (($res->"reasons")->[:len ($res->"reasons")]) \
				"mismatch package name, current $metaName, want $vat";
		}
	}
	# va: check meta type
	:if ([$InKeys "type" $va]) do={
		:local metaType [$ReadOption ($metaList->"type") $TypeofStr "code"];
		:local vat ($va->"type");
		:if ($metaType != ($va->"type")) do={
			:set (($res->"reasons")->[:len ($res->"reasons")]) \
				"mismatch package type, current $metaType, want $vat";
		}
	}
	# va: check meta ext
	:if ([$InKeys "ext" $va]) do={
		:local metaUrl [$ReadOption ($metaList->"url") $TypeofStr ""];
		:if ($metaUrl = "") do={
			:set (($res->"reasons")->[:len ($res->"reasons")]) \
				"mismatch package ext, url field should not be empty";
		} else {
			:if (![$StartsWith $metaUrl "http://"] and ![$StartsWith $metaUrl "https://"]) do={
				:set (($res->"reasons")->[:len ($res->"reasons")]) \
					"mismatch package ext, url field should be an URL";
			}
		}
	}
	# va: check meta local
	:if ([$InKeys "local" $va]) do={
		:local metaLocal [$ReadOption ($metaList->"local") $TypeofBool false];
		:if (!$metaLocal) do={
			:set (($res->"reasons")->[:len ($res->"reasons")]) \
				"mismatch package local, local flag should be setted";
		}
	}
	# va: check meta ext loose, ext + local
	:if ([$InKeys "extl" $va]) do={
		:local metaUrl [$ReadOption ($metaList->"url") $TypeofStr ""];
		:local metaLocal [$ReadOption ($metaList->"local") $TypeofBool false];
		:if ($metaUrl = "" and !$metaLocal) do={
			:set (($res->"reasons")->[:len ($res->"reasons")]) \
				"mismatch package extl, url should not be empty or local flag should be setted";
		}
	}
	# va: final
	:if ([:len ($res->"reasons")] = 0) do={
		:set ($res->"flag") true;
	}
	:return $res;
}


# $GetSource
# args: <str>                   <package name>
# return: <str>                 source of package
:global GetSource do={
	#DEFINE global
	:global IsNil;
	:global Replace;
	:global IsEmpty;
	# replace
	:local pkgName $1;
	:local fileName [$Replace $pkgName "." "_"];
	:local idList [/system/script/find name=$fileName];
	:if ([$IsEmpty $idList]) do={
		:error "Global.Package.GetSource: script \"$fileName\" not found.";
	}
	# get source;
	:local pSource [/system/script/get ($idList->0) source];
	:return $pSource;
}


# $GetMeta
# Get meta info by directly execute the entire source code.
# args: <str>                   find by <package name>
# opt kwargs: ID=<id>           find by id
# opt kwargs: VA=<array->str>   validate array
# return: <array->str>          meta named array
:global GetMeta do={
	#DEFINE global
	:global IsNil;
	:global IsNothing;
	:global Replace;
	:global IsEmpty;
	:global ReadOption;
	:global TypeofID;
	:global TypeofStr;
	:global TypeofArray;
	:global ValidateMetaInfo;
	# check
	:local tID;
	:local pkgName [$ReadOption $1 $TypeofStr ""];
	:local pID [$ReadOption $ID $TypeofID];
	:local pVA [$ReadOption $VA $TypeofArray];
	:if ($pkgName != "") do={
		:local fileName [$Replace $pkgName "." "_"];
		:local idList [/system/script/find name=$fileName];
		:if ([$IsEmpty $idList]) do={
			:error "Global.Package.GetMeta: script \"$fileName\" not found.";
		} else {
			:set tID ($idList->0);
		}
	}
	:if (![$IsNil $pID]) do={
		:set tID $pID;
		:set pkgName [$Replace [/system/script/get $pID name] "_" "."];
	}
	:if ([$IsNothing $tID]) do={
		:error "Global.Package.GetMeta: need either <name> or <id>.";
	}
	# parse code and get result;
	:local pSource [:parse [/system/script/get $tID source]];
	:local pkg [$pSource ];
	:local va {"name"=$pkgName};
	:if (![$IsNil $pVA]) do={
		:foreach k,v in $pVA do={
			:set ($va->$k) $v;
		}
	}
	# validate
	:local vres [$ValidateMetaInfo ($pkg->"metaInfo") $va];
	:if (!($vres->"flag")) do={
		:put "There are some errors in the meta info, check it first!";
		:foreach reason in ($vres->"reasons") do={
			:put "  $reason";
		}
		:error "Global.Package.GetMeta: could not validate target package.";
	}
	:return ($pkg->"metaInfo");
}


# $ParseMetaSafe
# Cut off the code snippet of metaInfo from content, parse it and return.
# args: <str>                   code string
# return: <array->str>          meta named array
:global ParseMetaSafe do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	# local
	:if (![$IsStr $1]) do={
		:error "Global.Package.ParseMetaSafe: \$1 should be string.";
	}
	:local source $1;
	:local pt ":local metaInfo {";
	:local start [:find $source $pt];
	:if ([$IsNil $start]) do={
		:error "Global.Package.ParseMetaSafe: could not find metaInfo.";
	}
	:local cursor ($start + [:len $pt]);
	:local count 1;
	:local flagQuote false;
	:local ch;
	:while ($count != 0 and $cursor < [:len $source]) do={
		:set ch [:pick $source $cursor];
		:if ($flagQuote) do={
			:if ($ch = "\\") do={
				:set cursor ($cursor + 1);
			}
			:if ($ch = "\"") do={
				:set flagQuote false;
			}
			:if ($ch ~ "[\$]") do={
				:error "Global.Package.ParseMetaSafe: pos: $cursor, unsafe char: $ch.";
			}
		} else {
			:if ($ch = "\"") do={
				:set flagQuote true;
			}
			:if ($ch ~ "[][\$:]") do={
				:error "Global.Package.ParseMetaSafe: pos: $cursor, unsafe char: $ch.";
			}
			:if ($ch = "{") do={
				:set count ($count + 1);
			}
			:if ($ch = "}") do={
				:set count ($count - 1);
			}
		}
		:set cursor ($cursor + 1);
	}
	:local snippet ([:pick $source $start $cursor] . "\r\n:return \$metaInfo;");
	:local cmd [:parse $snippet];
	:local metaInfo [$cmd];
	:return $metaInfo;
}


# $GetMetaSafe
# Get meta info by parsing the cutted code snippet.
# args: <str>                   find by <package name>
# opt kwargs: ID=<id>           find by id
# opt kwargs: VA=<array->str>   validate array
# return: <array->str>          meta named array
:global GetMetaSafe do={
	#DEFINE global
	:global IsNil;
	:global IsNothing;
	:global Replace;
	:global IsEmpty;
	:global ReadOption;
	:global TypeofID;
	:global TypeofStr;
	:global TypeofArray;
	:global ParseMetaSafe;
	:global NewArray;
	:global ValidateMetaInfo;
	# check
	:local tID;
	:local pkgName [$ReadOption $1 $TypeofStr ""];
	:local pID [$ReadOption $ID $TypeofID];
	:local pVA [$ReadOption $VA $TypeofArray];
	:if ($pkgName != "") do={
		:local fileName [$Replace $pkgName "." "_"];
		:local idList [/system/script/find name=$fileName];
		:if ([$IsEmpty $idList]) do={
			:error "Global.Package.GetMetaSafe: script \"$fileName\" not found.";
		} else {
			:set tID ($idList->0);
		}
	}
	:if (![$IsNil $pID]) do={
		:set tID $pID;
		:set pkgName [$Replace [/system/script/get $pID name] "_" "."];
	}
	:if ([$IsNothing $tID]) do={
		:error "Global.Package.GetMetaSafe: need either <name> or <id>.";
	}
	# manually parse code and get result
	:local source [/system/script/get $tID source];
	:local metaList [$ParseMetaSafe $source];
	# va
	:local va {"name"=$pkgName};
	:if (![$IsNil $pVA]) do={
		:foreach k,v in $pVA do={
			:set ($va->$k) $v;
		}
	}
	:local vres [$ValidateMetaInfo $metaList $va];
	if (!($vres->"flag")) do={
		:put "There are some errors in the meta info, check it first!";
		:foreach reason in ($vres->"reasons") do={
			:put "  $reason";
		}
		:error "Global.Package.GetMetaSafe: could not validate target package.";
	}
	:return $metaList;
}


# $GetEnv
# args: <str>                   <package name>
# return: <array->var>          env named array
:global GetEnv do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global RSplit;
	:global Replace;
	:global IsEmpty;
	:global ValidateMetaInfo;
	# replace
	:local pkgName $1;
	:local fileName [$Replace $pkgName "." "_"];
	:local idList [/system/script/find name=$fileName];
	:if ([$IsEmpty $idList]) do={
		:error "Global.Package.GetEnv: script \"$fileName\" not found.";
		:return $Nil;
	}
	# parse code and get result;
	:local pSource [:parse [/system/script/get ($idList->0) source]];
	:local pkg [$pSource ];
	:local va {"name"=$pkgName;"type"="env"};
	:local vres [$ValidateMetaInfo ($pkg->"metaInfo") $va];
	if (!($vres->"flag")) do={
		:put "There are some errors in the meta info, check it first!";
		:foreach reason in ($vres->"reasons") do={
			:put "  $reason";
		}
		:error "Global.Package.GetEnv: could not validate target package.";
	}
	:return $pkg;
}


# $PrintPackageInfo
# args: <str>                   <package name>
:global PrintPackageInfo do={
	#DEFINE global
	:global IsNil;
	:global GetMetaSafe;
	# local
	:local metaInfo [$GetMetaSafe $1];
	:put ("Package: " . $metaInfo->"name");
	:put ("Version: " . $metaInfo->"version");
	:put ("Description: " . $metaInfo->"description");
	:put ("Global Functions: " . [:len ($metaInfo->"global-functions")]);
	foreach function in ($metaInfo->"global-functions") do={
		:put ("    " . $function);
	}
	:return "";
}


# $LoadPackage
# args: <str>                   <package name>
:global LoadPackage do={
	#DEFINE global
	:global TypeofStr;
	:global ReadOption;
	:global Replace;
	:global IsEmpty;
	# load
	:local pkgName [$ReadOption $1 $TypeofStr ""];
	:if ($pkgName != "") do={
		:local fileName [$Replace $pkgName "." "_"];
		:local idList [/system/script/find name=$fileName];
		:if ([$IsEmpty $idList]) do={
			:error "Global.Package.LoadPackage: script \"$fileName\" not found."
		} else {
			/system/script/run $idList;
		}
	} else {
		:error "Global.Package.LoadPackage: \$1 is empty.";
	}
}


# $GetFunc
# args: <str>                   <package name>.<func name>
# return: <code>                target function
:global GetFunc do={
	#DEFINE global
	:global IsNil;
	:global IsNum;
	:global IsEmpty;
	:global IsNothing;
	:global RSplit;
	:global Replace;
	:global FindPackage;
	:global ValidateMetaInfo;
	# local
	:local pkg;
	:local func;
	# split package & function
	:local splitted [$RSplit $1 "." 1];
	:local pkgName ($splitted->0);
	:local funcName ($splitted->1);
	:local fileName [$Replace $pkgName "." "_"];
	:local idList [/system/script/find name=$fileName];
	:if ([$IsEmpty $idList]) do={
		:error "Global.Package.GetFunc: script \"$fileName\" not found.";
	}
	# parse code and get result
	:local pSource [:parse [/system/script/get ($idList->0) source]];
	:set pkg [$pSource ];
	:local va {"name"=$pkgName;"type"="code"};
	:local vres [$ValidateMetaInfo ($pkg->"metaInfo") $va];
	if (!($vres->"flag")) do={
		:put "There are some errors in the meta info, check it first!";
		:foreach reason in ($vres->"reasons") do={
			:put "  $reason";
		}
		:error "Global.Package.GetFunc: could not validate target package.";
	}
	# get func from package
	:set func ($pkg->$funcName);
	:if ([$IsNothing $func]) do={
		:error "Global.Package.GetFunc: function $funcName not found in package.";
	}
	:return $func;
}


# $DumpVar
# Dump a variable into string.
# args: <str>                       <variable name>
# args: <var>                       variable
# opt kwargs: Indent=<str>          indent string
# opt kwargs: StartIndent=<num>     start indent string count
# opt kwargs: Output=<str>          output format: str, array
# opt kwargs: Global=<bool>         default false, use global declaration if true
# opt kwargs: Return=<bool>         default true
:global DumpVar do={
	#DEFINE global
	:global IsNil;
	:global IsStr;
	:global IsArray;
	:global IsArrayN;
	:global NewArray;
	:global ReadOption;
	:global Extend;
	:global Join;
	:global StartsWith;
	:global TypeofArray;
	:global TypeofStr;
	:global TypeofNum;
	:global TypeofBool;
	# read option
	:local indent [$ReadOption $Indent $TypeofStr ("\t")];
	:local cursor [$ReadOption $StartIndent $TypeofNum 0];
	:local pOutput [$ReadOption $Output $TypeofStr "str"];
	:local pGlobal [$ReadOption $Global $TypeofBool false];
	:local pReturn [$ReadOption $Return $TypeofBool true];
	# set start indent
	:local si "";
	:for i from=1 to=$cursor step=1 do={
		:set si ($si . $indent);
	}
	# set declaration
	:local declare "local";
	:if ($pGlobal) do={:set declare "global"}
	# init LSL
	:local LSL [$NewArray ];
	:local flagType true;
	# str
	:if ($flagType and [$IsStr $2]) do={
		:set flagType false;
		:set ($LSL->0) "$si:$declare $1 \"$2\";";
	}
	# array empty
	:if ($flagType and [$IsArray $2] and ([:len $2] = 0)) do={
		:set flagType false;
		:set ($LSL->0) "$si:$declare $1 ({});";
	}
	# array
	:if ($flagType and [$IsArrayN $2]) do={
		:set flagType false;
		:set ($LSL->0) "$si:$declare $1 {";
		# queue structure
		# {
		#     [<father's line number>, <line number>, array];
		#     [0, 0, a1];
		#     [0, 3, a2];
		#     [0, 5, a3];
		# }
		:local flag true;
		:local queue [$NewArray ];
		:local queueNext [$NewArray ];
		:local sq {1; 0; $2};
		:set ($queueNext->0) $sq;
		:local deltaLN 0;
		:while ($flag) do={
			:if (![$IsArrayN $queueNext]) do={
				:set flag false;
			} else {
				:set queue $queueNext;
				:set queueNext [$NewArray ];
				:set deltaLN 0;
				:foreach node in $queue do={
					:local fatherLN ($node->0);
					:local selfLN ($node->1);
					:local subLSL [$NewArray ];
					:foreach k,v in ($node->2) do={
						# make indent
						:local ind "";
						:for i from=0 to=$cursor step=1 do={
							:set ind ($ind . $indent);
						}
						# make key
						:local ks "";
						:if ([:typeof $k] = $TypeofNum) do={
							:set ks "";
						} else {
							:set ks "\"$k\"="
						}
						# type specific
						:local fT true;
						:if ([:typeof $v] = $TypeofArray) do={
							:set fT false;
							:if ([:len $v] = 0) do={
								:local lineStr "$ind$ks({})";
								:set ($subLSL->[:len $subLSL]) $lineStr;
							} else {
								# add starting brace
								:local lineStr "$ind$ks{";
								:set ($subLSL->[:len $subLSL]) $lineStr;
								:local a [$NewArray ];
								:set ($a->0) ($fatherLN + $selfLN + $deltaLN);
								:set ($a->1) [:len $subLSL];
								:set ($a->2) $v;
								:set ($queueNext->[:len $queueNext]) $a;
								# add closing brace
								:local lineStr "$ind};";
								:set ($subLSL->[:len $subLSL]) $lineStr;
							}
						};
						:if ([:typeof $v] = $TypeofStr) do={
							:set fT false;
							:local lineStr;
							:local noquote "noquote:";
							:if ([$StartsWith $v $noquote]) do={
								:local vs [:pick $v [:len $noquote] [:len $v]];
								:set lineStr "$ind$ks$vs;";
							} else {
								:set lineStr "$ind$ks\"$v\";";
							}
							:set ($subLSL->[:len $subLSL]) $lineStr;
						}
						# rest of type
						:if ($fT) do={
							:local lineStr "$ind$ks$v;";
							:set ($subLSL->[:len $subLSL]) $lineStr;
						}

					}
					# extend here
					:set LSL [$Extend $LSL $subLSL ($deltaLN + $fatherLN + $selfLN)];
					:set deltaLN ($deltaLN + [:len $subLSL]);
				}
				:set cursor ($cursor + 1);
			}
		}
		:set ($LSL->[:len $LSL]) "$si}";
	}
	# the rest type
	:if ($flagType) do={
		:set ($LSL->0) "$si:$declare $1 $2;";
	}
	# handle return
	:if ($pReturn = true) do={
		:set ($LSL->[:len $LSL]) ":return \$$1;";
	}
	:if ($pOutput = "array") do={
		:return $LSL;
	}
	# join into string
	:local LS [$Join ("\r\n") $LSL];
	:return $LS;
}


# $LoadVar
# Load a string into variable.
# args: <str>                       <variable>
:global LoadVar do={
	:local varFunc [:parse $1];
	:local var [$varFunc ];
	:return $var;
}


# $SetGlobalVar
# Set global variables.
# TODO: let it still work after reboot
# args: <str>                       variable's name
# args: <var>                       variable's value, not nil
# opt kwargs: Timeout=<time>        timeout(sec)
:global SetGlobalVar do={
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global IsStr;
	:global Join;
	:global TypeofStr;
	:global TypeofTime;
	:global ReadOption;
	:global TypeRecovery;
	:global GetCurrentDatetime;
	:global ShiftDatetime;
	:global ToSDT;
	# check
	:if (![$IsStr $1]) do={
		:error "Global.Package.SetGlobalVar: \$1 should be str.";
	};
	:local name $1;
	:if ([$IsNothing $2] or [$IsNil $2]) do={
		:error "Global.Package.SetGlobalVar: \$2 should be neither nothing nor nil.";
	};
	# FIXME: :local value [$TypeRecovery $2];
	# [$TypeRecovery "0.1.0"] -> 0.0.0.1(ip)
	:local value $2;
	:local timeout [$ReadOption $Timeout $TypeofTime 0:0:0]
	:if ($timeout < 0:0:0) do={
		:error "Global.Package.SetGlobalVar: \$Timeout should greater than 00:00:00.";
	};
	:local funcStr;
	:if ([:typeof $value] = $TypeofStr) do={
		:set funcStr ":global $name \"$value\";";
	} else {
		:set funcStr ":global $name $value;";
	};
	# parse exec
	:local func [:parse $funcStr];
	[$func ];
	# timeout check
	:if ($timeout > 0:0:0 and $timeout < 0:0:30) do={
		:error "Global.Package.SetGlobalVar: \$Timeout should longer than 30 seconds.";
	}
	# timeout
	:if ($timeout > 0:0:0) do={
		:local cdt [$GetCurrentDatetime ];
		:local tdt [$ShiftDatetime $cdt $timeout];
		:local sdt [$ToSDT $tdt];
		:local startTime ($sdt->"time");
		:local startDate ($sdt->"date");
		:local scheduleName "ROSPM_SetGlobalVar_$name_Timeout";
		:local scheduleComment "managed by ROSPM";
		:local idList [/system/scheduler/find name=$scheduleName];
		:if ([$IsEmpty $idList]) do={
			:local eventStrList {
				"/system/script/environment/remove $name;";
				"/system/scheduler/remove $scheduleName;";
			}
			:local eventStr [$Join ("\r\n") $eventStrList];
			/system/scheduler/add name=$scheduleName comment=$scheduleComment \
				start-date=$startDate start-time=$startTime on-event=$eventStr;
		} else {
			:local sID ($idList->0);
			/system/scheduler/set numbers=$sID start-date=$startDate start-time=$startTime;
		}
	}
}


# $LoadGlobalVar
# Load global variables from environment, raise error if value is nil or nothing.
# args: <str>                       variable's name
# return: <var>                     value, return nil if not found
:global LoadGlobalVar do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global IsStr;
	:global IsEmpty;
	:global IsNothing;
	# check
	:if (![$IsStr $1]) do={
		:error "Global.Package.LoadGlobalVar: \$1 should be str.";
	};
	:local varName $1;
	# load
	:local eID [/system/script/environment/find name=$varName];
	:if ([$IsEmpty $eID]) do={
		:return $Nil;
	} else {
		:local funcStr ":global $varName;:return \$$varName;";
		:local func [:parse $funcStr];
		:local result [$func ];
		:if ([$IsNil $result] or [$IsNothing $result]) do={
			:error "Global.Package.LoadGlobalVar: load a nil or nothing value.";
		};
		:return $result;
	}
}


# $UnsetGlobalVar
# Unset a global variable.
# args: <str>                       variable's name
:global UnsetGlobalVar do={
	#DEFINE global
	:global IsNil;
	:global IsStrN;
	:global IsEmpty;
	# check
	:if (![$IsStrN $1]) do={:error "Global.Package.UnsetGlobalVar: \$1 should be a string."};
	:local varName $1;
	# from environment
	/system/script/environment/remove [/system/script/environment/find name=$varName];
	# from scheduler
	:local scheduleName "ROSPM_SetGlobalVar_$varName_Timeout";
	/system/scheduler/remove [/system/scheduler/find name=$scheduleName];
}


# $CompareVersion
# Compare two version strings.
# args: <str>                       version1
# args: <str>                       version2
# return: <num>                     positive if version1 > version2
:global CompareVersion do={
	#DEFINE global
	:global IsNil;
	:global Count;
	:global RSplit;
	# check
	:local vs1 [:tostr $1];
	:local vs2 [:tostr $2];
	:if (!($vs1~"^([0-9]+\\.){2}[0-9]+(\\.[a-z])?\$")) do={
		:error "Global.Package.CompareVersion: \$1 should follow regex \"^([0-9]+\\.){2}[0-9]+(\\.[a-z])?\$\""
	}
	:if (!($vs2~"^([0-9]+\\.){2}[0-9]+(\\.[a-z])?\$")) do={
		:error "Global.Package.CompareVersion: \$2 should follow regex \"^([0-9]+\\.){2}[0-9]+(\\.[a-z])?\$\""
	}
	# local
	:local vlen1 [$Count $1 "."];
	:local vlen2 [$Count $2 "."];
	:local va1 "|";
	:local va2 "|";
	:if ($vlen1=3) do={
		:local splitted [$RSplit $vs1 "." 1];
		:set vs1 ($splitted->0);
		:set va1 ($splitted->1);
	}
	:if ($vlen2=3) do={
		:local splitted [$RSplit $vs2 "." 1];
		:set vs2 ($splitted->0);
		:set va2 ($splitted->1);
	}
	:local van1 [:convert $va1 to="num"];
	:local van2 [:convert $va2 to="num"];
	# compare
	:if ($vs1>$vs2) do={
		:return 1;
	}
	:if ($vs1<$vs2) do={
		:return -1;
	}
	:return ($van1 - $van2);
}


# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
