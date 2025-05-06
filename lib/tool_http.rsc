#!rsc by RouterOS
# ===================================================================
# |       ROSPM Packages      |   tool.http
# ===================================================================
# ALL package level functions follows lower camel case.
# http utility
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="tool.http";
	"version"="0.5.0";
	"description"="http utility";
};


# $verifyURL
# verify url is legal or not.
# kwargs: URL=<str>                     target url
# return: <bool>                        legal or not
:local verifyURL do={
	#DEFINE global
	:global IsStrN;
	# local
	:if ([$IsStrN $URL]) do={
		:if ($URL ~ "^http(s)?://") do={
			:return true;
		}
	}
	:return false;
}


# $makeHeaders
# make http header
# kwargs: Headers=<array->str>          http header array or Nil
# return: <str>                         http header str
:local makeHeaders do={
	#DEFINE global
	:global IsNil;
	:global NewArray;
	:global Join;
	# local
	# TODO: add version info
	:local headers {
		"User-Agent"="Mikrotik/ROSPM";
	}
	:if (![$IsNil $Headers]) do={
		:foreach k,v in $Headers do={
			:set ($headers->$k) $v;
		}
	}
	:local hList [$NewArray ];
	:foreach k,v in $headers do={
		:set ($hList->[:len $hList]) "$k: $v";
	}
	:local hStr [$Join "," $hList];
	:return $hStr;
}


# $makeQueryParams
# kwargs: Params=<array->str>           Query params
# return: <str>                         query params string
:local makeQueryParams do={
	#DEFINE global
	:global NewArray;
	:global Join;
	# local
	:local qpList [$NewArray ];
	:foreach k,v in $Params do={
		:set ($qpList->[:len $qpList]) "$k=$v";
	}
	:local qpStr [$Join "&" $qpList];
	:return $qpStr;
}


# $makeHttpBody
# kwargs: Headers=<array->str>          http headers
# kwargs: Data=<obj>                    Data
# kwargs: DataType=<str>                type of data
# return: <str>                         http body
:local makeHttpBody do={
	#DEFINE global
	:global IsStr;
	:global IsArray;
	:global GetFunc;
	# local
	:if (![$IsArray $Headers]) do={
		:error "tool.http.makeHttpBody: \$Headers shoud be array";
	}
	:if (![$IsStr $DataType]) do={
		:error "tool.http.makeHttpBody: \$DataType shoud be str";
	}
	:local flag true;
	# data type switch
	:local dataStr;
	:if ($flag and ($DataType = "form-data")) do={
		:set flag false;
		:set ($Headers->"Content-Type") "multipart/form-data";
		:error "tool.http.makeHttpBody: not implement form-data"
	};
	:if ($flag and ($DataType = "form-urlencoded")) do={
		:set flag false;
		:set ($Headers->"Content-Type") "application/x-www-form-urlencoded";
		:error "tool.http.makeHttpBody: not implement x-www-form-urlencoded"
	};
	:if ($flag and ($DataType = "json")) do={
		:set flag false;
		:set ($Headers->"Content-Type") "application/json";
		:set dataStr [:serialize $Data to=json];
	};
	:if ($flag and ($DataType = "text")) do={
		:set flag false;
		:set ($Headers->"Content-Type") "text/plain";
		:error "tool.http.makeHttpBody: not implement text"
	};
	:if ($flag) do={
		:error "tool.http.makeHttpBody: unknown data type: $DataType"
	};
	:return $dataStr;
}


# $makeOutput
# kwargs: Result=<array->str>           http fetch result
# kwargs: Output=<str>                  output: text(default), json
# return: <array->str>                  http result
:local makeOutput do={
	#DEFINE global
	:global NewArray;
	:global GetFunc;
	# local
	:local respResult [$NewArray ];
	:local flag true;
	:if (($Result->"status") = "finished") do={
		:set ($respResult->"status") 200;
		:set ($respResult->"data") ($Result->"data");
	} else {
		:error "tool.http.makeOutput: status not finished";
	}
	# op is json
	:if ($flag and ($Output = "text")) do={
		:set flag false;
	}
	:if ($flag and ($Output = "json")) do={
		:set flag false;
		:local js [:deserialize ($respResult->"data") from=json];
		:set ($respResult->"json") $js;
	}
	:if ($flag) do={
		:error "tool.http.makeOutput: unknown \$Output: $Output";
	}
	:return $respResult;
}


# $httpGet
# kwargs: URL=<str>                     target url
# opt kwargs: Retry=<num>               retry count if error
# opt kwargs: Headers=<array->str>      http headers
# opt kwargs: Params=<array->str>       Query params
# opt kwargs: Suppress=<bool>           default false, suppress the error or not
# opt kwargs: Output=<str>              output: text(default), json
# return: <array->str>                  http response
:local httpGet do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global IsStrN;
	:global TypeofStr;
	:global TypeofBool;
	:global TypeofArray;
	:global ReadOption;
	:global GetFunc;
	# local
	:local pURL [$ReadOption $URL $TypeofStr ""];
	:local pHeaders [$ReadOption $Headers $TypeofArray];
	:local pParams [$ReadOption $Params $TypeofArray];
	:local pRetry [$ReadOption $Retry $TypeofStr 0];
	:local pSuppress [$ReadOption $Suppress $TypeofBool false];
	:local pOutput [$ReadOption $Output $TypeofStr "text"];
	:local rawResult;
	# check
	:if (![[$GetFunc "tool.http.verifyURL"] URL=$pURL]) do={:error "tool.http.httpGet: \$URL illegal"};
	# headers
	:if ([$IsNil $pHeaders]) do={
		:set pHeaders {
			"Accept"="*/*";
		};
	}
	:if ($pOutput = "json") do={
		:set ($pHeaders->"Accept") "application/json";
	}
	# assemble header
	:local headers [[$GetFunc "tool.http.makeHeaders"] Headers=$pHeaders];
	# make query params
	:local qps "";
	:if (![$IsNil $pParams]) do={
		:set qps [[$GetFunc "tool.http.makeQueryParams"] Params=$pParams];
	}
	:local urlStr "$pURL";
	:if ($qps != "") do={
		:set urlStr ($urlStr . "\?$qps");
	}
	# do request
	:do {
		:set rawResult [/tool fetch url=$urlStr http-header-field=$headers output="user" as-value];
	} on-error={
		:if ($pSuppress) do={
			:return $Nil;
		}
		:put "Got error when requesting $pURL";
		:put "Currently, vanilla fetch tool only support http response with a 200 status code, even 30x is not supported!";
		:error "tool.http.httpGet: http status code not 200";
	}
	# make output
	:local result [[$GetFunc "tool.http.makeOutput"] Result=$rawResult Output=$pOutput];
	:return $result;
}


# $httpPost
# kwargs: URL=<str>                     target url
# opt kwargs: Retry=<num>               retry count if error
# opt kwargs: Headers=<array->str>      http headers
# opt kwargs: Params=<array->str>       Query params
# opt kwargs: Data=<array->str>         Data
# opt kwargs: DataType=<str>            type of data
# opt kwargs: Suppress=<bool>           default false, suppress the error or not
# opt kwargs: Output=<str>              output: text(default), json
# return: <array->str>                  http response
:local httpPost do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global TypeofStr;
	:global TypeofBool;
	:global TypeofArray;
	:global ReadOption;
	:global GetFunc;
	# local
	:local pURL [$ReadOption $URL $TypeofStr ""];
	:local pHeaders [$ReadOption $Headers $TypeofArray];
	:local pParams [$ReadOption $Params $TypeofArray];
	:local pData [$ReadOption $Data $TypeofArray];
	:local pDataType [$ReadOption $DataType $TypeofStr "form-urlencoded"];
	:local pRetry [$ReadOption $Retry $TypeofStr 0];
	:local pSuppress [$ReadOption $Suppress $TypeofBool false];
	:local pOutput [$ReadOption $Output $TypeofStr "text"];
	:local rawResult;
	# check
	:if (![[$GetFunc "tool.http.verifyURL"] URL=$pURL]) do={:error "tool.http.httpPost: \$URL illegal"};
	# headers
	:if ([$IsNil $pHeaders]) do={
		:set pHeaders {
			"Accept"="*/*";
		};
	}
	:if ($pOutput = "json") do={
		:set ($pHeaders->"Accept") "application/json";
		:set ($pHeaders->"Content-type") "application/json";
	}
	# assemble header
	:local headers [[$GetFunc "tool.http.makeHeaders"] Headers=$pHeaders];
	# make query params
	:local qps "";
	:if (![$IsNil $pParams]) do={
		:set qps [[$GetFunc "tool.http.makeQueryParams"] Params=$pParams];
	}
	:local urlStr "$pURL";
	:if ($qps != "") do={
		:set urlStr ($urlStr . "\?$qps");
	}
	# make data
	:local data [[$GetFunc "tool.http.makeHttpBody"] Headers=$pHeaders Data=$pData DataType=$pDataType];
	# do request
	:do {
		:set rawResult [/tool fetch url=$urlStr http-method="post" http-header-field=$headers http-data=$data output="user" as-value];
	} on-error={
		:if ($pSuppress) do={
			:return $Nil;
		}
		:put "Got error when requesting $pURL";
		:put "Currently, vanilla fetch tool only support http response with a 200 status code, even 30x is not supported!";
		:error "tool.http.httpPost: http status code not 200";
	}
	# make output
	:local result [[$GetFunc "tool.http.makeOutput"] Result=$rawResult Output=$pOutput];
	:return $result;
}


# $httpPut
# kwargs: URL=<str>                     target url
# opt kwargs: Retry=<num>               retry count if error
# opt kwargs: Headers=<array->str>      http headers
# opt kwargs: Params=<array->str>       Query params
# opt kwargs: Data=<array->str>         Data
# opt kwargs: DataType=<str>            type of data
# opt kwargs: Suppress=<bool>           default false, suppress the error or not
# opt kwargs: Output=<str>              output: text(default), json
# return: <array->str>                  http response
:local httpPut do={
	#DEFINE global
	:global Nil;
	:global IsNil;
	:global TypeofStr;
	:global TypeofBool;
	:global TypeofArray;
	:global ReadOption;
	:global GetFunc;
	# local
	:local pURL [$ReadOption $URL $TypeofStr ""];
	:local pHeaders [$ReadOption $Headers $TypeofArray];
	:local pParams [$ReadOption $Params $TypeofArray];
	:local pData [$ReadOption $Data $TypeofArray];
	:local pDataType [$ReadOption $DataType $TypeofStr "form-urlencoded"];
	:local pRetry [$ReadOption $Retry $TypeofStr 0];
	:local pSuppress [$ReadOption $Suppress $TypeofBool false];
	:local pOutput [$ReadOption $Output $TypeofStr "text"];
	:local rawResult;
	# check
	:if (![[$GetFunc "tool.http.verifyURL"] URL=$pURL]) do={:error "tool.http.httpPut: \$URL illegal"};
	# headers
	:if ([$IsNil $pHeaders]) do={
		:set pHeaders {
			"Accept"="*/*";
		};
	}
	:if ($pOutput = "json") do={
		:set ($pHeaders->"Accept") "application/json";
		:set ($pHeaders->"Content-type") "application/json";
	}
	# assemble header
	:local headers [[$GetFunc "tool.http.makeHeaders"] Headers=$pHeaders];
	# make query params
	:local qps "";
	:if (![$IsNil $pParams]) do={
		:set qps [[$GetFunc "tool.http.makeQueryParams"] Params=$pParams];
	}
	:local urlStr "$pURL";
	:if ($qps != "") do={
		:set urlStr ($urlStr . "\?$qps");
	}
	# make data
	:local data [[$GetFunc "tool.http.makeHttpBody"] Headers=$pHeaders Data=$pData DataType=$pDataType];
	# do request
	:do {
		:set rawResult [/tool fetch url=$urlStr http-method="put" http-header-field=$headers http-data=$data output="user" as-value];
	} on-error={
		:if ($pSuppress) do={
			:return $Nil;
		}
		:put "Got error when requesting $pURL";
		:put "Currently, vanilla fetch tool only support http response with a 200 status code, even 30x is not supported!";
		:error "tool.http.httpPut: http status code not 200";
	}
	# make output
	:local result [[$GetFunc "tool.http.makeOutput"] Result=$rawResult Output=$pOutput];
	:return $result;
}


# $httpDelete
# kwargs: URL=<str>                     target url
# opt kwargs: Retry=<num>               retry count if error
# opt kwargs: Headers=<array->str>      http headers
# opt kwargs: Params=<array->str>       Query params
# opt kwargs: Suppress=<bool>           default false, suppress the error or not
# opt kwargs: Output=<str>              output: text(default), json
# return: <array->str>                  http response
:local httpDelete do={
}


:local package {
	"metaInfo"=$metaInfo;
	"verifyURL"=$verifyURL;
	"makeHeaders"=$makeHeaders;
	"makeQueryParams"=$makeQueryParams;
	"makeHttpBody"=$makeHttpBody;
	"makeOutput"=$makeOutput;
	"httpGet"=$httpGet;
	"httpPost"=$httpPost;
	"httpPut"=$httpPut;
	"httpDelete"=$httpDelete;
}
:return $package;
