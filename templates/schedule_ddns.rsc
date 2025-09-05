#DEFINE global
:global IsNil;
:global IsEmpty;
:global IsNothing;
:global FindPackage;
:global GetFunc;
:global GetConfig;

# local
:local cFlag true;
:local configName "config.ddns";
:local schedulerName "{{ schedulerName }}";
:local alwaysUpdate {{ alwaysUpdateFlag }};
:local addrListName "IP_DDNS_$schedulerName";

# load config
:if ([$IsEmpty [$FindPackage $configName]]) do={
	:log/error "ROSPM DDNS: config.ddns not found";
	:error "config.ddns not found";
}
:local config [$GetConfig $configName];
:local cfgScheduler (($config->"scheduler")->$schedulerName);
:if ([$IsNothing $cfgScheduler]) do={
	:log/error "ROSPM DDNS: scheduler $schedulerName not found in config file";
	:error "scheduler $schedulerName not found in config file";
}

# load from config
:local ipProvider ($cfgScheduler->"ipProvider");
:local ipProviderParams ($cfgScheduler->"ipProviderParams");
:local serviceProvider ($cfgScheduler->"serviceProvider");
:local serviceProviderParams ($cfgScheduler->"serviceProviderParams");

# get ip addr
:local ipAddr;
:do {
	:set ipAddr [[$GetFunc $ipProvider] Params=$ipProviderParams];
} on-error={
	:log/warning "ROSPM DDNS: $schedulerName: get ip address failed, the Provider is $ipProvider";
	:set cFlag false;
}
:log/debug "ROSPM DDNS: $schedulerName: get ip address $ipAddr from provider $ipProvider";

# determine update or not
:if ($cFlag and !$alwaysUpdate) do={
	:local idList [/ip/firewall/address-list/find list="$addrListName"];
	:if (![$IsEmpty $idList]) do={
		:local ipAddrLast [/ip/firewall/address-list/get ($idList->0) address];
		:if ($ipAddrLast = $ipAddr) do={
			:log/debug "ROSPM DDNS: $schedulerName: no need to update address list";
			:set cFlag false;
		}
	}
}

# update record by service provider function
:local result;
:if ($cFlag) do={
	:do {
		:set result [[$GetFunc $serviceProvider] IP=$ipAddr Params=$serviceProviderParams];
	} on-error={
		:log/error "ROSPM DDNS: $schedulerName: unexpected error occurred, the service provider is $serviceProvider";
		:set cFlag false;
	}
}

# update check
:if ($cFlag) do={
	:local res ($result->"result");
	:log/info "ROSPM DDNS: $schedulerName: schedule result is $res";
	:if ($res != "updated") do={
		:log/warning "ROSPM DDNS: $schedulerName: service provider got in trouble, it is $serviceProvider";
		:foreach v in ($result->"advice") do={
			:log/warning "ROSPM DDNS: $schedulerName: response is $v";
		}
		:set cFlag false;
	}
}

# finally
:if ($cFlag) do={
	/ip/firewall/address-list remove [/ip/firewall/address-list/find list="$addrListName"];
	/ip/firewall/address-list add list="$addrListName" address=$ipAddr;
	:log/info "ROSPM DDNS: $schedulerName: address list $addrListName updated";
	:foreach v in ($result->"advice") do={
		:log/info "ROSPM DDNS: $schedulerName: response is $v";
	}
}
