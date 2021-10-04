# global declare
:global Nil;
:global GetFunc;
# local
:local name {{ name }};
:local ipGetterFunc {{ ipGetterFunc }};
:local ipGetterParams {{ ipGetterParams }};
:local serviceProviderFunc {{ serviceProviderFunc }};
:local serviceProviderParams {{ serviceProviderParams }};

# get ip addr
:local ipAddr;
:do {
    :set ipAddr [[$GetFunc $ipGetterFunc] Params=$ipGetterParams];
} on-error={
    :log warning "schedule.tool.ddns: $name, get ip address failed, the getter is $ipGetterFunc";
    :return $Nil;
}
:log info "schedule.tool.ddns: $name, get ip address $ipAddr, the getter is $ipGetterFunc";

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
    :set result [[$GetFunc $serviceProviderFunc] IP=$ipAddr Params=$serviceProviderParams];
} on-error={
    :log error "schedule.tool.ddns: $name, unexpected error occurred, the service provider is $serviceProviderFunc";
}
:local rs ($result->"result")
:if ($rs = "error") do={
    :log warning "schedule.tool.ddns: $name, service provider got in trouble, it is $serviceProviderFunc";
    :foreach v in ($result->"advice") do={
        :log warning "$v";
    }
} else {
    :log info "schedule.tool.ddns: $name, schedule result is $rs";
    :foreach v in ($result->"advice") do={
        :log info "$v";
    }
}
