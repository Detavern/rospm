# global package
:global IsNil;
:global GetFunc;

:local intfList "{{ InterfaceList }}";
:local bindedAddressList "{{ AddressList }}";

# find ip
:local intfIPList [[$GetFunc "ip.address.find"] InterfaceList=$intfList];

# check ip existance
:if ([:len $intfIPList] = 0) do={
    :log error "ROSPM Watcher: no ip found on $intfList!";
    [/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=$bindedAddressList]];
    :error "no ip found";
}

# check address list
:local cnt 0;
:foreach v in $intfIPList do={
    :local idList [/ip/firewall/address-list/find list=$bindedAddressList address=$v !disabled];
    :if ([:len $idList] > 0) do={
        :set cnt ($cnt + 1);
    } else {
        :log info "ROSPM Watcher: current ip $v not found in address list $bindedAddressList.";
    }
}

# compare
if ($cnt < [:len $intfIPList]) do={
    :log info "ROSPM Watcher: updating address list $bindedAddressList ..."
    [/ip/firewall/address-list/remove [/ip/firewall/address-list/find list=$bindedAddressList]];
    [[$GetFunc "ip.firewall.address.ensureAddressList"] List=$bindedAddressList AddressList=$intfIPList];
}
