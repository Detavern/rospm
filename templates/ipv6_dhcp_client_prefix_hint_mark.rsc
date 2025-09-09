:if ($"pd-valid" = 1) do={
	#DEFINE global
	:global Nil;
	:global QuoteRegexMeta;
	# local
	:local rtTable "{{ routingTable }}";
	:local idList [/ipv6/pool/find prefix=$"pd-prefix"];
	:if ([:len $idList] < 1) do={
		:log/error ("ipv6.dhcp.client: could not found pool of prefix " . $"pd-prefix");
		:return $Nil;
	}
	:local poolName [/ipv6/pool/get ($idList->0) name];
	:local idList [/ipv6/dhcp-client/find pool-name=$poolName disabled=no];
	:if ([:len $idList] < 1) do={
		:log/error "ipv6.dhcp.client: could not found dhcp client of pool $poolName";
		:return $Nil;
	}
	# routing rule
	:local cmnt "managed by ROSPM | $poolName";
    # clean
    :local cleanMark [$QuoteRegexMeta $cmnt];
    /routing/rule/remove [/routing/rule/find comment~"^$cleanMark"];
    # add
	/routing/rule/add comment=$cmnt src-address=[:tostr $"pd-prefix"] action="lookup" table=$rtTable;
	:log/info "ipv6.dhcp.client: updating routing rule for $poolName";
	# update hint
	/ipv6/dhcp-client/set ($idList->0) prefix-hint=[:tostr $"pd-prefix"];
}
