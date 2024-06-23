# Global

## recover type
{
    :put "testing recover type...";
    :local srcV [$TypeRecovery "1.1.1.1/24"];
    :local dstV 1.1.1.1/24;
    $Assert ($srcV=$dstV) "recover type error";
}

## positional args
{
    :put "testing positional arguments...";
    :local v 1.1.1.1;
    :local Foo do={
        :local t1 [:typeof $1];
        :local t2 [:typeof $2];
        :local t3 [:typeof $3];
        $Assert ($t1=$TypeofIP) "t1 should be ip";
        $Assert ($t2=$TypeofStr) "t2 should be string";
        $Assert ($t3=$TypeofNothing) "t3 should be nothing";
    }

    [$Foo $v 1.1.1.1];
}

## keyword args
{
    :put "testing keyword arguments...";
    :local v 1.1.1.1;
    :local Foo do={
        :local t1 [:typeof $a];
        :local t2 [:typeof $b];
        :local t3 [:typeof $c];
        $Assert ($t1=$TypeofIP) "t1 should be ip";
        $Assert ($t2=$TypeofStr) "t2 should be string";
        $Assert ($t3=$TypeofNothing) "t3 should be nothing";
    }

    [$Foo a=$v b=1.1.1.1];
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
    :local app [$Append $a 5];
    $Print $app;
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

{
    :local a {"WAN-PPP";"WAN-ETH";"WAN-PPP";"WAN-ETH"};
    :put $a;
    :put [$UniqueArray $a];
}

## ensure one of item found by command is enabled
:put [$ItemsFoundEnsureOneEnabled "/interface ethernet " ];


# global package

## setglobalvar with timeout
[$SetGlobalVar "VAR" "hello world" Timeout=10w];

# error
[$SetGlobalVar "VAR" $Nil Timeout=10w];
[$SetGlobalVar "VAR" $Nothing Timeout=10w];

## load global
$Print [$LoadGlobalVar "VAR"];

### error
$Print [$LoadGlobalVar "Nil"];
$Print [$LoadGlobalVar "Nothing"];

## unset
[$UnsetGlobalVar "VAR"];


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
    :foreach k,v in $a do={
        :put ("key   " . $k . " is " . [:typeof $k]);
        :put ("value " . $v . " is " . [:typeof $v]);
    }
}
{
    :local a {1;2;3;4;5;6};
    $Print $a;
    :local key 1.1.1.1;
    $Print $key;
    :set ($a->$key) 321;
    $Print $a;
    :foreach k,v in $a do={
        :put ("key   " . $k . " is " . [:typeof $k]);
        :put ("value " . $v . " is " . [:typeof $v]);
    }
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
    [$func ];
    :global test;
    $Print $test;
}

## timedelta type
{
    :local start 12:00:00;
    :local end 12:12:00;
    :local delta ($start - $end);
    $Print $delta;
}

## date type
{
    :local clock [/system clock print as-value];
    :local date ($clock->"date");
    :local time ($clock->"time");
    $Print $date;
    $Print $time;
}

## change value of sub array

### v6 is okay
{
    :local m {
        "a"={
            "aa"="vaa";
            "ab"="vab";
            "ac"="vac";
        }
        "b"={
            "ba"="vba";
            "bb"="vbb";
            "bc"="vbc";
        }
    };
    :local a ($m->"a");
    :local b ($m->"b");
    :set ($a->"aa") "new vaa";
    $Print $a;
    $Print $m;
}

## v7 should be
{
    :local m {
        "a"={
            "aa"="vaa";
            "ab"="vab";
            "ac"="vac";
        }
        "b"={
            "ba"="vba";
            "bb"="vbb";
            "bc"="vbc";
        }
    };
    :set (($m->"a")->"aa") "new vaa";
    $Print $m;
}

## change value in array when iter

### v6 is okay
{
    :local m {
        {
            "name"="alice";
            "age"="20";
            "id"="1";
        };
        {
            "name"="bob";
            "age"="21";
            "id"="2";
        };
        {
            "name"="cat";
            "age"="22";
            "id"="3";
        }
    }
    :foreach v in $m do={
        :set ($v->"age") 25;
    };
    $Print $m;
}

### v7 should be
{
    :local m {
        {
            "name"="alice";
            "age"="20";
            "id"="1";
        };
        {
            "name"="bob";
            "age"="21";
            "id"="2";
        };
        {
            "name"="cat";
            "age"="22";
            "id"="3";
        }
    }
    :for i from=0 to=([:len $m] - 1) do={
        :set (($m->i)->"age") 25;
    }
    $Print $m;
}

## change value in another func

### v6 is okay
{
    :local js {
        "name"="alice";
        "age"="20";
        "id"="1";
    }
    :local foo do={
        :set ($JSP->"age") 25;
        $Print $JSP;
    }
    [$foo JSP=$js];
    $Print $js;
}

### v7 should be
{
    :local js {
        "name"="alice";
        "age"="20";
        "id"="1";
    }
    :local foo do={
        :set ($JSP->"age") 25;
        :return $JSP;
    }
    :set js [$foo JSP=$js];
    $Print $js;
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

# rospm config
$Print [$GetFunc "rospm.install" $a];

## loadRemoteScript
{
    :local url "https://raw.githubusercontent.com/Detavern/rospm/master/res/startup.rsc";
    :local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$url Normalize=true];
    /system scheduler remove [/system scheduler find name="rospm-startup"];
    /system scheduler add name="rospm-startup" start-time=startup on-event=$scriptStr;
}

## firstRun
{
    :local config {
        "baseURL"="https://raw.githubusercontent.com/Detavern/rospm/master/";
        "owner"="rospm";
    }
    [[$GetFunc "rospm.firstRun"] Context=$config];
}

## check package status
$Print [[$GetFunc "rospm.checkPackageStatus"] ];

{
    :local a {
        "a"=1;
    }
    $Print ($a->"a");
    $Print ($a->"b");
}

## update
[[$GetFunc "rospm.update"]];


## config update
{
    :local a {
        "test"="test";
    };
    [$UpdateConfig "config.rospm.package.ext" $a];
}

## upgrade
[[$GetFunc "rospm.upgrade"] Package="rospm"];
[[$GetFunc "rospm.upgrade"] Package="rospm.hello-world"];

# rospm.state

## check version
[[$GetFunc "rospm.state.checkVersion"] ForceUpdate=true];


## checkState
$Print [[$GetFunc "rospm.state.checkState"] Package="rospm"];
$Print [[$GetFunc "rospm.state.checkState"] Package="notexist"];
