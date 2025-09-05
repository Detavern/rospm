#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   ddns.service.provider.cloudflare
# ===================================================================
# ALL package level functions follows lower camel case.
# Provides functions for managing DNS records using the Cloudflare API.
#
# Copyright (c) 2020-2025 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
# Use cloudflare v4 api
:local metaInfo {
	"name"="ddns.service.provider.cloudflare";
	"version"="0.7.0";
	"description"="Provides functions for managing DNS records using the Cloudflare API.";
	"essential"=false;
	"global"=false;
};


# $verifyToken
# kwargs: Token=<str>                       api token
# return: <bool>                            true if verified
:local verifyToken do={
	#DEFINE global
	:global IsNil;
	:global GetFunc;
	# local
	:local headers {
		"Authorization"="Bearer $Token";
	}
	:local url "https://api.cloudflare.com/client/v4/user/tokens/verify";
	:local resp [[$GetFunc "tool.http.httpGet"] URL=$url Headers=$headers Suppress=true Output="json"];
	:if ([$IsNil $resp]) do={
		:return false;
	};
	:do {
		:local js ($resp->"json");
		:if ($js->"success") do={
			:if ((($js->"result")->"status") = "active") do={
				:return true;
			}
		}
		:return false;
	} on-error={
		:put "ddns.provider.cloudflare.verifyToken: got error when handling response";
		:return false;
	}
}

# $getZoneID
# kwargs: Token=<str>                       api token
# kwargs: Name=<str>                        zone name
# return: <str>                             zone id
:local getZoneID do={
	#DEFINE global
	:global IsStr;
	:global GetFunc;
	# local
	:if (![$IsStr $Name]) do={:error "ddns.provider.cloudflare.getZoneID: \$Name should be string"}
	:if (!($Name ~ "^[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})\$")) do={
		:error "ddns.provider.cloudflare.getZoneID: \$Name should be a domain";
	}
	:local url "https://api.cloudflare.com/client/v4/zones";
	:local headers {
		"Authorization"="Bearer $Token";
	}
	:local params {
		"name"=$Name;
	}
	:local resp [[$GetFunc "tool.http.httpGet"] URL=$url Headers=$headers Params=$params Output="json"];
	:local js ($resp->"json");
	:if ($js->"success") do={
		:if ((($js->"result_info")->"count") > 0) do={
			:foreach v in ($js->"result") do={
				:if (($v->"name") = $Name) do={
					:if (($v->"status") = "active") do={
						:return ($v->"id");
					} else {
						:error "ddns.provider.cloudflare.getZoneID: this zone is no longer active: $Name";
					}
				}
			}
		}
		:error "ddns.provider.cloudflare.getZoneID: cannot find specific zone name: $Name";
	}
	:error "ddns.provider.cloudflare.getZoneID: handle response error";
}


# $findDNSRecord
# find one dns record id by its name and type.
# kwargs: Token=<str>                       api token
# kwargs: ZoneID=<str>                      zone id
# kwargs: Name=<str>                        record name, should be FQDN
# kwargs: Type=<str>                        record type,  A, AAAA, CNAME, TXT, MX, ...
# for more valid values of Type, you could have a look at cloudflare's official document.
# return: <array->str>                      record item list
:local findDNSRecord do={
	#DEFINE global
	:global Nil;
	:global IsStr;
	:global GetFunc;
	:global NewArray;
	# local
	:if (![$IsStr $Name]) do={:error "ddns.provider.cloudflare.findDNSRecord: \$Name should be string"}
	:if (!($Name ~ "^[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})\$")) do={:error "ddns.provider.cloudflare.findDNSRecord: \$Name should be a domain"}
	:if (![$IsStr $Type]) do={:error "ddns.provider.cloudflare.findDNSRecord: \$Type should be string"}
	:local url "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records";
	:local headers {
		"Authorization"="Bearer $Token";
	}
	:local params {
		"match"="all";
		"name"=$Name;
		"type"=$Type;
	}
	:local resp [[$GetFunc "tool.http.httpGet"] URL=$url Headers=$headers Params=$params Output="json"];
	:local js ($resp->"json");
	:if ($js->"success") do={
		:local result [$NewArray ];
		:if ((($js->"result_info")->"count") > 0) do={
			:foreach v in ($js->"result") do={
				:if (($v->"name") = $Name) do={
					:set ($result->[:len $result]) $v;
				}
			}
		}
		:return $result;
	}
	:error "ddns.provider.cloudflare.findDNSRecord: handle response error";
}


# $createDNSRecord
# kwargs: Token=<str>                       api token
# kwargs: ZoneID=<str>                      zone id
# kwargs: Data=<array->str>                 post data
# return: <array->str>                      record item list
# data example {
#     "name"=<reocrd name>;
#     "type"=<record type>;
#     "content"=$IP;
#     "ttl"=300;
#     "priority"="";        opt, for mx srv uri records.
#     "proxied"=false;      opt, default false.
# }
:local createDNSRecord do={
	#DEFINE global
	:global Nil;
	:global IsStr;
	:global IsNil;
	:global ReadOption;
	:global TypeofArray;
	:global GetFunc;
	:global NewArray;
	# local
	:local pData [$ReadOption $Data $TypeofArray];
	:if (![$IsStr $ZoneID]) do={:error "ddns.provider.cloudflare.createDNSRecord: \$ZoneID should be string"}
	:if ([$IsNil $pData]) do={:error "ddns.provider.cloudflare.createDNSRecord: \$Data should be array"}
	:local url "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records";
	:local headers {
		"Authorization"="Bearer $Token";
	}
	:local resp [[$GetFunc "tool.http.httpPost"] URL=$url Headers=$headers Data=$pData DataType="json" Output="json"];
	:local js ($resp->"json");
	:if ($js->"success") do={
		:local result ($js->"result");
		:return $result;
	} else {
		:error "ddns.provider.cloudflare.createDNSRecord: got error";
	}
}


# $updateDNSRecord
# kwargs: Token=<str>                       api token
# kwargs: ZoneID=<str>                      zone id
# kwargs: RecordID=<str>                    record id
# kwargs: Data=<array->str>                 post data
# return: <array->str>                      result
:local updateDNSRecord do={
	#DEFINE global
	:global Nil;
	:global IsStr;
	:global IsNil;
	:global ReadOption;
	:global TypeofArray;
	:global GetFunc;
	:global NewArray;
	# local
	:local pData [$ReadOption $Data $TypeofArray];
	:if (![$IsStr $ZoneID]) do={:error "ddns.provider.cloudflare.updateDNSRecord: \$ZoneID should be string"}
	:if (![$IsStr $RecordID]) do={:error "ddns.provider.cloudflare.updateDNSRecord: \$RecordID should be string"}
	:if ([$IsNil $pData]) do={:error "ddns.provider.cloudflare.updateDNSRecord: \$Data should be array"}
	:local url "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$RecordID";
	:local headers {
		"Authorization"="Bearer $Token";
	}
	:local resp [[$GetFunc "tool.http.httpPut"] URL=$url Headers=$headers Data=$pData DataType="json" Output="json"];
	:local js ($resp->"json");
	:if ($js->"success") do={
		:local result ($js->"result");
		:return $result;
	} else {
		:error "ddns.provider.cloudflare.updateDNSRecord: got error";
	}
}


# $deleteDNSRecord
# kwargs: Token=<str>                       api token
# kwargs: ZoneID=<str>                      zone id
# kwargs: RecordID=<str>                    record id
# return: <array->str>                      result
:local deleteDNSRecord do={
	#DEFINE global
	:global Nil;
	:global IsStr;
	:global ReadOption;
	:global GetFunc;
	:global NewArray;
	# local
	:if (![$IsStr $ZoneID]) do={:error "ddns.provider.cloudflare.deleteDNSRecord: \$ZoneID should be string"}
	:if (![$IsStr $RecordID]) do={:error "ddns.provider.cloudflare.deleteDNSRecord: \$RecordID should be string"}
	:local url "https://api.cloudflare.com/client/v4/zones/$ZoneID/dns_records/$RecordID";
	:local headers {
		"Authorization"="Bearer $Token";
	}
	:local resp [[$GetFunc "tool.http.httpDelete"] URL=$url Headers=$headers Data=$pData DataType="json" Output="json"];
	:local js ($resp->"json");
	:if ($js->"success") do={
		:local result ($js->"result");
		:return $result;
	} else {
		:error "ddns.provider.cloudflare.deleteDNSRecord: got error";
	}
}


# $ensureHostRecord
# kwargs: IP=<ip>                           ip address or ipv6 address
# kwargs: Params=<array->str>               provider function params
# return: <array->str>                      result
# Params={
#     "token"="<the api token got from cloudflare>";
#     "zoneName"="<the name of dns zone, if use this, the zoneID will be ignored. example: ddns.com>";
#     "recordName"="<the name of dns record, should be an A or AAAA record>";
# }
# result={
#     "result"="created";           created, updated, same, error
#     "advice"={
#         "some advice 1";
#         "some advice 2";
#     };
# }
:local ensureHostRecord do={
	#DEFINE global
	:global IsStr;
	:global IsArray;
	:global IsIP;
	:global IsIPv6;
	:global IsEmpty;
	:global EndsWith;
	:global TypeofStr;
	:global NewArray;
	:global Print;
	:global GetFunc;
	# result
	:local recordType;
	:local advice [$NewArray ];
	:local result {
		"result"="error";
		"advice"=$advice;
	}
	# check
	:if ([$IsIP $IP]) do={
		:set recordType "A";
	} else {
		:if ([$IsIPv6 $IP]) do={
			:set recordType "AAAA";
		} else {
			:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: \$IP should be IP or IPv6";
			:return $result;
		}
	}
	:if (![$IsArray $Params]) do={
		:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: require \$Params";
		:return $result;
	}
	# complete the recordName
	:if (![$EndsWith ($Params->"recordName") ($Params->"zoneName")]) do={
		:set ($Params->"recordName") (($Params->"recordName") . "." . ($Params->"zoneName"));
	}
	# verify token
	:local token ($Params->"token");
	:local valid [[$GetFunc "ddns.provider.cloudflare.verifyToken"] Token=$token];
	:if (!$valid) do={
		:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: verify token failed";
		:set ($advice->[:len $advice]) "this may occurred due to network issue, firewall issue or invaild token";
		:return $result;
	}
	# get zone id by its name
	:local zoneID;
	:local zoneName ($Params->"zoneName");
	:do {
		:set zoneID [[$GetFunc "ddns.provider.cloudflare.getZoneID"] Token=$token Name=$zoneName];
	} on-error={
		:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: get zone id failed: $recordName";
		:return $result;
	}
	# find dns record id
	:local recordName ($Params->"recordName");
	:local recordList;
	:do {
		:set recordList [[$GetFunc "ddns.provider.cloudflare.findDNSRecord"] Token=$token ZoneID=$zoneID Name=$recordName Type=$recordType];
	} on-error={
		:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: get record id list failed: $recordName";
		:return $result;
	}
	# prepare data
	:local data;
	:if ([$IsEmpty $recordList]) do={
		# create an A/AAAA record
		:set data {
			"name"=$recordName;
			"type"=$recordType;
			"content"=$IP;
			"ttl"=60;
		}
		:do {
			[[$GetFunc "ddns.provider.cloudflare.createDNSRecord"] Token=$token ZoneID=$zoneID Data=$data];
		} on-error={
			:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: create record failed: $recordName";
			:return $result;
		}
		:set ($result->"result") "created";
		:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: ip record created $IP";
		:return $result;
	} else {
		# update the A/AAAA record
		# take the first id
		:local recordItem ($recordList->0);
		:local recordID ($recordItem->"id");
		:local recordIP [:toip ($recordItem->"content")];
		:if ($recordIP = $IP) do={
			# same ip, needn't to update
			:set ($result->"result") "same";
			:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: same ip on record: $IP, do nothing";
			:return $result;
		} else {
			# update it
			:set data {
				"type"=$recordType;
				"name"=$recordName;
				"content"=$IP;
				"ttl"=($recordItem->"ttl");
			}
			:do {
				[[$GetFunc "ddns.provider.cloudflare.updateDNSRecord"] Token=$token ZoneID=$zoneID RecordID=$recordID Data=$data];
			} on-error={
				:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: update record failed: $recordName";
				:return $result;
			}
			:set ($result->"result") "updated";
			:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: ip changed from $recordIP to $IP";
			:return $result;
		}
	}
	:set ($advice->[:len $advice]) "ddns.provider.cloudflare.ensureHostRecord: unexpected error, please open an issue!";
	:return $result;
}


:local package {
	"metaInfo"=$metaInfo;
	"verifyToken"=$verifyToken;
	"getZoneID"=$getZoneID;
	"findDNSRecord"=$findDNSRecord;
	"createDNSRecord"=$createDNSRecord;
	"updateDNSRecord"=$updateDNSRecord;
	"deleteDNSRecord"=$deleteDNSRecord;
	"ensureHostRecord"=$ensureHostRecord;
}
:return $package;
