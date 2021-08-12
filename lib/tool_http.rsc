:local metaInfo {
    "name"="tool.http";
    "version"="0.1.0";
    "description"="http utility";
};


# $httpGet
# kwargs: URL=<str>
# opt kwargs: Retry=<num>               retry count if error
# opt kwargs: Output=<num>              str(default), file, json
# opt kwargs: Headers=<array->str>      http headers
# return: <array->str>                  http response
:local httpGet do={
    #DEFINE global
    :global IsNil;
    :global IsNothing;
    :global IsArray;
    :global IsEmpty;
    :global TypeofStr;
    :global TypeofArray;
    :global NewArray;
    :global Print;
    :global Split;
    :global Append;
    :global ReadOption;
    :global GetFunc;
    # local
    :local pOutput [$ReadOption $Output $TypeofStr "str"];
    :local pRetry [$ReadOption $Retry $TypeofStr 0];
    :local rawResult;
    :local result [$NewArray ];
    # op is str
    :if ($pOutput = "str") do={
        :set rawResult [/tool fetch url=$URL output="user" as-value];
        :if (($rawResult->"status") = "finished") do={
            :set ($result->"status") 200;
            :set ($result->"data") ($rawResult->"data");
        } else {
            :error "tool.http.httpGet: status error";
        }
    }
    :return $result;
}


:local package {
    "metaInfo"=$metaInfo;
    "httpGet"=$httpGet;
}
:return $package;
