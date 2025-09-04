#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   tool.sms
# ===================================================================
# ALL package level functions follows lower camel case.
# This package offers tools for SMS.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="tool.sms";
	"version"="0.7.0.a";
	"description"="This package offers tools for SMS.";
};


# $sendText
# Send simple text message by SMS
# kwargs: Params=<params>
# params:
#   kwargs: phone-number=<str>
#   kwargs: message=<str>
#   opt kwargs: port=<str>
:local sendText do={
	# /tool/sms> send port=LTE type=class-1 status-report-request="no" phone-number="+17252228899" message="HI Asta, you forgot to take your keys!"
	#DEFINE global
	:global IsNil;
	:global IsEmpty;
	:global IsNothing;
	:global TypeofArray;
	:global TypeofStr;
	:global ReadOption;
	:global RunCommand;
	# read params
	:local params [$ReadOption $Params $TypeofArray];
	:if ([$IsNil $params]) do={:error "tool.sms.sendText: require \$Params"}
	:if ([$IsEmpty $params]) do={:error "tool.sms.sendText: require options in \$Params"}
	# read opt
	:local phoneNumber [$ReadOption ($params->"phone-number") $TypeofStr];
	:if ([$IsNil $phoneNumber]) do={
		:error "tool.sms.sendText: require phone-number in \$Params";
	}
	:local message [$ReadOption ($params->"message") $TypeofStr];
	:if ([$IsNil $message]) do={
		:error "tool.sms.sendText: require message in \$Params";
	}
	:local portIntf [$ReadOption ($params->"port") $TypeofStr];
	:if ([$IsNil $portIntf]) do={
		:local idList [/interface/lte/find];
		:if ([:len $idList]<1) do={
			:error "tool.sms.sendText: no lte interface found";
		}
		:set ($params->"port") [/interface/lte/get number=($idList->0) name];
	} else {
		:local idList [/interface/lte/find name=$portIntf];
		:if ([:len $idList]<1) do={
			:error "tool.sms.sendText: target port=$portIntf not found";
		}
	}
	:if ([$IsNothing ($params->"type")]) do={
		:set ($params->"type") "class-1";
	}
	:if ([$IsNothing ($params->"status-report-request")]) do={
		:set ($params->"status-report-request") no;
	}
	# local
	[$RunCommand "/tool/sms/send" $params];
}


:local package {
	"metaInfo"=$metaInfo;
	"sendText"=$sendText;
}
:return $package;
