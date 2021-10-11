#!rsc by RouterOS
# ===================================================================
# |       RSPM Packages      |   tool.remote
# ===================================================================
# ALL package level functions follows lower camel case.
# remote script load tools
#
# Copyright (c) 2020-2021 detavern <detavern@live.com>
# https://github.com/Detavern/rspm/blob/master/LICENSE.md
#
:local metaInfo {
    "name"="tool.remote";
    "version"="0.3.0";
    "description"="remote script load tools";
};


# $loadRemoteSource
# load remote script from url and put into strings
# kwargs: URL=<str>                 url of remote script
# opt kwargs: Normalize=<bool>      false(default), normalize the eol by "\r\n"
# return: <str>                     remote script source
:local loadRemoteSource do={
    #DEFINE global
    :global Split;
    :global Join;
    :global Strip;
    :global NewArray;
    :global ReadOption;
    :global TypeofBool;
    :global TypeofStr;
    :global StartsWith;
    :global GetFunc;
    :global ScriptLengthLimit;
    # local
    :local pNormalize [$ReadOption $Normalize $TypeofBool false];
    :local pURL [$ReadOption $URL $TypeofStr ""];
    :local result;
    :if ($pURL = "") do={
        :error "tool.remote.loadRemoteSource: need \$URL";
    }
    :if (![$StartsWith $pURL "http://"] and ![$StartsWith $pURL "https://"]) do={
        :error "tool.remote.loadRemoteSource: url scheme not supported";
    }
    # get source
    :local resp [[$GetFunc "tool.http.httpGet"] URL=$pURL];
    :if ($pNormalize) do={
        :local splitted [$Split ($resp->"data") ("\n")];
        :local stripList [$NewArray];
        :foreach line in $splitted do={
            :local lineS [$Strip $line ("\r")];
            :set ($stripList->[:len $stripList]) $lineS;
        };
        :set result [$Join ("\r\n") $stripList];
    } else {
        :set result ($resp->"data");
    };
    :local lenResult [:len $result];
    :if ($lenResult > $ScriptLengthLimit) do={
        :error "tool.remote.loadRemoteSource: package string length($lenResult) exceed limit";
    }
    :return $result;
}


# $loadRemoteVar
# load remote script from url and parse into value
# kwargs: URL=<str>                 url of remote script
# return: <str>                     remote script value
:local loadRemoteVar do={
    #DEFINE global
    :global ReadOption;
    :global TypeofStr;
    :global StartsWith;
    :global GetFunc;
    :global LoadVar;
    :global ScriptLengthLimit;
    # local
    :local pURL [$ReadOption $URL $TypeofStr ""];
    :if ($pURL = "") do={
        :error "tool.remote.loadRemoteVar: need \$URL";
    }
    :if (![$StartsWith $pURL "http://"] and ![$StartsWith $pURL "https://"]) do={
        :error "tool.remote.loadRemoteVar: url scheme not supported";
    }
    # get source
    :local resp [[$GetFunc "tool.http.httpGet"] URL=$pURL];
    :local source ($resp->"data");
    :local lenResult [:len $source];
    :if ($lenResult > $ScriptLengthLimit) do={
        :error "tool.remote.loadRemoteVar: package string length($lenResult) exceed limit";
    }
    :local value [$LoadVar $source];
    :return $value;
}


:local package {
    "metaInfo"=$metaInfo;
    "loadRemoteSource"=$loadRemoteSource;
    "loadRemoteVar"=$loadRemoteVar;
}
:return $package;
