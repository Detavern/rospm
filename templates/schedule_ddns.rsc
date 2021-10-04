# global declare
:global Nil;
:global GetFunc;
:global GetConfig;

# local
:local configName {{ configName }};
:local config;
# load config
:do {
    :set config [$GetConfig $configName];
} on-error={
    :log error "schedule.tool.ddns: missing config: $configName";
}

# load from config
:local name ($config->"name");
:local ipGetter ($config->"ipGetter");
:local ipGetterParams ($config->"ipGetterParams");
:local serviceProvider ($config->"serviceProvider");
:local serviceProviderParams ($config->"serviceProviderParams");

# get ip addr
:local ipAddr;
:do {
    :set ipAddr [[$GetFunc $ipGetter] Params=$ipGetterParams];
} on-error={
    :log warning "schedule.tool.ddns.<$name>: get ip address failed, the getter is $ipGetter";
    :return $Nil;
}
:log info "schedule.tool.ddns.<$name>: get ip address $ipAddr, the getter is $ipGetter";

# Update the host record by service provider function.
# That function should not raise ANY exception,
# and the return value should obey the following structure.
# example return {
#     "result"="created";           created, updated, same, error
#     "advice"={
#         "some advice 1";
#         "some advice 2";
#     };
# }
:local result;
:do {
    :set result [[$GetFunc $serviceProvider] IP=$ipAddr Params=$serviceProviderParams];
} on-error={
    :log error "schedule.tool.ddns.<$name>: unexpected error occurred, the service provider is $serviceProvider";
}
:local rs ($result->"result")
:if ($rs = "error") do={
    :log warning "schedule.tool.ddns.<$name>: service provider got in trouble, it is $serviceProvider";
    :foreach v in ($result->"advice") do={
        :log warning "$v";
    }
} else {
    :log info "schedule.tool.ddns.<$name>: schedule result is $rs";
    :foreach v in ($result->"advice") do={
        :log info "$v";
    }
}
