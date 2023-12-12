# global declare
:global Nil;
:global IsEmpty;
:global IsNothing;
:global FindPackage;
:global GetFunc;
:global GetConfig;

# local
:local configName "config.ddns";
:local schedulerName "{{ schedulerName }}";

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
    :return $Nil;
}
:log/info "ROSPM DDNS: $schedulerName: get ip address $ipAddr from provider $ipProvider";

# Update the host record by service provider function.
:local result;
:do {
    :set result [[$GetFunc $serviceProvider] IP=$ipAddr Params=$serviceProviderParams];
} on-error={
    :log/error "ROSPM DDNS: $schedulerName: unexpected error occurred, the service provider is $serviceProvider";
}
:local rs ($result->"result")
:if ($rs = "error") do={
    :log/warning "ROSPM DDNS: $schedulerName: service provider got in trouble, it is $serviceProvider";
    :foreach v in ($result->"advice") do={
        :log/warning "$v";
    }
} else {
    :log/info "ROSPM DDNS: $schedulerName: schedule result is $rs";
    :foreach v in ($result->"advice") do={
        :log/info "$v";
    }
}
