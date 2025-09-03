# /ip/pool

## ensure

### ensure a pool
{
    [[$GetFunc "ip.pool.ensure"] Params=({
        "name"="test-pool";
        "ranges"="192.168.1.10-192.168.1.20";
    })]
}

### ensure a pool use network
{
    [[$GetFunc "ip.pool.ensure"] Params=({
        "name"="test-pool";
        "network"="192.168.1.0/24";
    })]
}

### ensure a pool use full network
{
    [[$GetFunc "ip.pool.ensure"] Params=({
        "name"="test-pool";
        "network"="192.168.1.0/24";
        "range-offset"=100;
        "range-count"=50;
    })]
}