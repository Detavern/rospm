# Global

## recover type
{
    :put "testing recover type...";
    :local srcV [$RecoverType "1.1.1.1/24"];
    :local dstV 1.1.1.1/24;
    $Assert ($srcV=$dstV) "recover type error";
}

## replace
:put [$Replace "abcd abc ab a" "ab" "xx"];
:put [$Replace "hello world" "hello" "new"];
:put [$Replace "interface.ethernet" "." "_"];

## reverse
:put [$Reverse {1; 2; 3; 4; 5} ];

## StartsWith
:put [$StartsWith "hello world" "hello"];
:put [$StartsWith "hello world" "hello x"];

## EndsWith
:put [$EndsWith "hello world" "world"];
:put [$EndsWith "hello world" "x world"];

## split
:put [$Split ".a.b.c." "."];
### ;a;b;c;""
:put [$Split "a->b->c->d" "->"];
### a;b;c;d
:put [$Split "a.b.c.d" "." 1];
### a;b.c.d
:put [$Split "a.b.c.d" "." 2];
### a;b;c.d

## rsplit
:put [$RSplit ".a.b.c." "."];
:put [$RSplit "->a->b->c->d" "->"];
:put [$RSplit "a.b.c.d" "." 1];


{
    :local string "a->b->c->d";
    :local post [:pick $string 9 10];
    :put ($post)
}

## join
{
    :local sp ",";
    :local a [$NewArray];
    $Print [$Join $sp $a];
    :set ($a->0) 1;
    $Print [$Join $sp $a];
    :set ($a->1) 2;
    $Print [$Join $sp $a];
}

## strip
{
    :local str "  VAR\n \r ";
    :local stripped [$Strip $str];
    :put [:len $stripped];
    :put $stripped;
}
{
    :local str "  VAR\n \r ";
    :local stripped [$Strip $str Mode="l"];
    :put [:len $stripped];
    :put $stripped;
}
{
    :local str "  VAR\n \r ";
    :local stripped [$Strip $str Mode="r"];
    :put [:len $stripped];
    :put $stripped;
}
## in
{
    :local a {1;2;3;4;5};
    :put [$InValues 1 $a];
}
{
    :local a {"a"=1;"b"=2;"c"=3;"d"=4};
    :put [$InKeys "a" $a];
}

## append
{
    :local a {1;2;3;4};
    :put [$Append $a 5];
}
{
    :local a {1;2;3};
    :local b {4;5};
    :put [$Append $a $b];
}

## prepend
{
    :local a {2;3;4;5};
    :put [$Prepend $a 1];
}
{
    :local a {3;4;5};
    :local b {1;2};
    :put [$Prepend $a $b];
}
## insert
{
    :local a {1;2;3;5};
    :local v {7;8};
    $Print [$Insert $a 0 0];
    $Print [$Insert $a 4 3];
    $Print [$Insert $a 6 4];
    $Print [$Insert $a $v 4];
}
## extend
{
    :local a {1;2;3;9};
    :local v {5;6};
    $Print [$Extend $a $v];
    $Print [$Insert $a $v 3];
}

## simple dump & load
{
    :local a 123456;
    :put [$SimpleDump $a];
}
{
    :local a 123456;
    :put [$SimpleLoad $a];
}
:put [$SimpleLoad "error|123456"];
:put [$SimpleLoad "str|123456"];
:put [$SimpleLoad "num|123456"];
:put [$SimpleLoad "ip|1.1.1.1"];
:put [$SimpleLoad "array|1;1;1;1.1.1.1"];

## dump variable & load
{
    :local var 1;
    :local varStr [$DumpVar "var" $var];
    $Print $varStr;
    :put "load test";
    $Print [$LoadVar $varStr];
}
{
    :local var "dwadawdw";
    :local varStr [$DumpVar "var" $var];
    $Print $varStr;
    :put "load test";
    $Print [$LoadVar $varStr];
}
{
    :local var 1.1.1.1/24;
    :local varStr [$DumpVar "var" $var];
    $Print $varStr;
    :put "load test";
    $Print [$LoadVar $varStr];
}
{
    :local var {
        "scope-1"="value scope-1";
        "scope-2"={
            "scope-2-1"={
                "scope-2-1-1"="value scope-2-1-1";
            };
            "scope-2-2"="value scope-2-2";
        };
        "scope-3"={
            "scope-3-1"="value scope-3-1";
            "scope-3-2"="value scope-3-2";
            "scope-3-3"="value scope-3-3";
            "scope-3-4"="value scope-3-4";
            "scope-3-5"="value scope-3-5";
        }
    };
    :local varStr [$DumpVar "var" $var];
    $Print $varStr;
    :put "load test";
    $Print [$LoadVar $varStr];
}

## unique
{
    :local a {1;2;3;4;5;3;4;5;6;7;9;20;"20"};
    :put $a;
    :put [$UniqueArray $a];
}

## GetConfig
:put [$GetConfig "config.rspm"];

## create config
{
    :local config {
        "packageList"="noquote:\$packageList";
        "description"="noquote:\$description";
    };
    :local add {
        "packageList"={
            "p1"={
                "version"="0.0.1";
            };
            "p2"={
                "version"="0.0.1";
            };
            "p3"={
                "version"="0.0.1";
            };
        };
        "description"="some description";
    };
    :put [$CreateConfig "config.rspm" $config $add];
}


## ensure one of item found by command is enabled
:put [$ItemsFoundEnsureOneEnabled "/interface ethernet " ];


# Some Marginal situation

## wrong array
{
    :local a {1,2,3,4};
    :local b {1;2;3;4;"a"=5};
    :put $a;
    :put $b;
    $Print $a;
    $Print $b;
}

## why we need NewArray
{
    :local array $EmptyArray;
    :set ($array->3) "value";
    :put $array;
    :put $EmptyArray;
}

## array key value type test
{
    :local a {0=1;1=3;2=5;3=7;4=9;99=123};
    $Print $a;
    :set ($a->"98") 321;
    $Print $a;
}
{
    :local a {
        0=0;
        true=true;
        "3"="3";
        "*1"="*1";
        0.0.0.0=0.0.0.0;
        "0.0.0.0/0"=0.0.0.0/0;
    };
    :foreach k,v in $a do={
        :put ("key   " . $k . " is " . [:typeof $k]);
        :put ("value " . $v . " is " . [:typeof $v]);
    }
}

## why we need an additional [] out of GetFunc
{
    # ip
    :local ipA 1.1.1.1;
    # correct
    [[$GetFunc "ip.firewall.address-list.ensureAddress"] List="IP_WAN" Address=$ipA];
    # wrong, got only string or nothing inside function
    [$GetFunc "ip.firewall.address-list.ensureAddress"] List="IP_WAN" Address=$ipA;
}

## embbeded array
{
    :local ea {
        "a"={
            "aa"={
                "aaa"="1";
            };
            "bb"=1;
        };
        "b"=1;
    };
    $Print $ea;
    $Print ($ea->"a");
    $Print (($ea->"a")->"aa");
}

## no recusive
{
    :local recu do={
        :if ($1>1) do={
            :put $1;
            $recu ($1-1);
        } else {
            :put "end";
        }
    }
    $recu 1;
    $recu 2;
}

## array with uncontinues keys
{
    :local a [$NewArray];
    :set ($a->8) "v8";
    :set ($a->4) "v4";
    :set ($a->0) "v0";
    :set ($a->2) "v2";
    :set ($a->6) "v6";
    :foreach k,v in $a do={
        $Print $k;
        $Print $v;
    }    
}

## parsed global
{
    :local funcStr ":global test 1.1.1.1;";
    :local func [:parse $funcStr];
    $Print $test;
}

# Global helpers

## itemsFoundEnsureOneEnabled


# hello world
:put [[$GetFunc "hello-world.helloWorld"] ];
:put [[$GetFunc "hello-world.helloWorld"] name="RouterOS"];

# interface ethernet
## /interface ethernet

## rename 
:put [[$GetFunc "interface.ethernet.renameEthernet"] srcDefaultName="ether1" iName="ETH-T"];
:put [[$GetFunc "interface.ethernet.renameEthernet"] srcName="ETH-T" iName="ETH-1"];
## use default name to reset all ethernet
:put [[$GetFunc "interface.ethernet.resetDefaultName"] ];
## rename all ethernet's name by template 
{
    :local template {"ether"="ETH-"; "sfp"="SFP-"; "sfp-sfpplus"="SFPP-"};
    :put [[$GetFunc "interface.ethernet.renameAllByTemplate"] template=$template];
}

# interface list
## /interface list

## addList
:put [[$GetFunc "interface.list.addList"] iName="WAN"];
## ensure list
:put [[$GetFunc "interface.list.ensureList"] iName="WAN"];
## set list attr
{
    :local attrs {
        "include"=$Nil;
        "exclude"=$Nil;
    };
    :put [[$GetFunc "interface.list.setListAttrs"] iName="WAN" iAttrs=$attrs ];
}
## ensure list include
{
    :local includeList {"WAN_ETH"; "WAN_PPP"; "WAN_VPN"};
    :put [[$GetFunc "interface.list.ensureListInclude"] iName="WAN" includeList=$includeList];
}
### error example
{
    :local includeList {"all"};
    :put [[$GetFunc "interface.list.ensureListInclude"] iName="NOT_EXIST" includeList=$includeList];
}
{
    :local includeList {"NOT_EXIST"};
    :put [[$GetFunc "interface.list.ensureListInclude"] iName="WAN" includeList=$includeList];
}
## ensure list exclude
{
    :local excludeList {"WAN_ETH"; "WAN_PPP"; "WAN_VPN"};
    :put [[$GetFunc "interface.list.ensureListExclude"] iName="WAN" excludeList=$excludeList];
}
### error example
{
    :local excludeList {"all"};
    :put [[$GetFunc "interface.list.ensureListExclude"] iName="NOT_EXIST" excludeList=$excludeList];
}
{
    :local excludeList {"NOT_EXIST"};
    :put [[$GetFunc "interface.list.ensureListExclude"] iName="WAN" excludeList=$excludeList];
}
## find interface
:put [[$GetFunc "interface.list.findAllInterface"] ListName="WAN"];


## /interface list member
## ensure list member
{
    :local intfList {"ETH-1"; "ETH-2"};
    :put [[$GetFunc "interface.list.ensureListMember"] iName="WAN_ETH" intfList=$intfList];
}
### error example
{
    :local intfList {"ETH-1"; "ETH-2"};
    :put [[$GetFunc "interface.list.ensureListMember"] iName="NOT_EXIST" intfList=$intfList];
}
{
    :local intfList {"NOT_EXIST"};
    :put [[$GetFunc "interface.list.ensureListMember"] iName="NOT_EXIST" intfList=$intfList];
}

{
    :local pos -1;
    :set pos [:find "adw" "a" 1];
    :put $pos;
    :put [:typeof $pos];
    :put ([$IsNil v=$pos]);
    :put ([$IsNothing v=$pos]);
}

{
    :local myFunc [:parse [/system script get "test" source]];
    :put [$myFunc name="dawda"];
}

:global Test do={
    :local myFunc [:parse [/system script get "test" source]];
    :put [$myFunc name=$Nothing];
}

# /ip address
## get address
:put [[$GetFunc "ip.address.findAllAddress"] Interface="ETH-1"];
{
    :local intfList {"ETH-1"; "ETH-2"};
    :put [[$GetFunc "ip.address.findAllAddress"] InterfaceList=$intfList];
}
:put [[$GetFunc "ip.address.findAllAddress"] InterfaceList="WAN"];


# /ip route
## get gateway
:put [[$GetFunc "ip.route.getGateway"] DstAddress="0.0.0.0/0"];
:put [[$GetFunc "ip.route.getGateway"] DstAddress=0.0.0.0/0 RoutingMark="IRT_INTERNET"];
### error example
:put [[$GetFunc "ip.route.getGateway"] DstAddress=0.0.0.0/0 RoutingMark="NOT_EXIST"];

## ensure static route
:put [[$GetFunc "ip.route.ensureStaticRoute"] DstAddress="0.0.0.0/0" Gateway="172.20.0.253" RoutingMark="IRT_INTERNET" Distance=200];

### error example
:put [[$GetFunc "ip.route.ensureStaticRoute"] DstAddress="0.0.0.0/0"];

# /ip route rule
## ensure rule
:put [[$GetFunc "ip.route.rule.ensureRule"] DstAddress="10.0.0.0/8" Table="172.20.0.253"];

# /ip firewall address-list
## ensure address
:put [[$GetFunc "ip.firewall.address-list.ensureAddress"] List="TEST" Address="172.31.0.0/16"];
## ensure addresslist
{
    :local addressList {"172.16.1.0/24"; "172.16.2.0/24"; "172.16.3.0/24"};
    :put [[$GetFunc "ip.firewall.address-list.ensureAddressList"] List="TEST" AddressList=$addressList];
}

# tool

## http
:put [[$GetFunc "tool.http.httpGet"] URL="https://raw.githubusercontent.com/Detavern/rspm/master/rspm-installer.rsc"];
$Print [[$GetFunc "tool.http.httpGet"] URL="https://raw.githubusercontent.com/Detavern/rspm/master/res/package-info.rsc"];

# rspm config
$Print [$GetFunc "rspm.install" $a];

## loadRemoteScript
{
    :local url "https://raw.githubusercontent.com/Detavern/rspm/master/res/startup.rsc";
    :local scriptStr [[$GetFunc "rspm.loadRemoteScript"] URL=$url Normalize=true];
    /system scheduler remove [/system scheduler find name="rspm-startup"];
    /system scheduler add name="rspm-startup" start-time=startup on-event=$scriptStr;
}

## firstRun
{
    :local config {
        "BaseURL"="https://raw.githubusercontent.com/Detavern/rspm/master/";
        "Owner"="rspm";
    }
    $Print [[$GetFunc "rspm.firstRun"] Context=$config];
}

## check package status
$Print [[$GetFunc "rspm.checkPackageStatus"] ];

{
    :local a {
        "a"=1;
    }
    $Print ($a->"a");
    $Print ($a->"b");
}


## config update
{
    :local a {
        "a"={
            "aa"={
                "aao"="value aao";
            };
            "a1"="value ao";
        };
        "b"={
            "example.package.name"="custom";
            "bb"={
                "bbb"={
                    0=1.1.1.1;
                    1=2.2.2.2;
                    2=3.3.3.3;
                };
            };
        };
        "other"=123;
    };
    $Print [$UpdateConfig "config.rspm" $a];
}


