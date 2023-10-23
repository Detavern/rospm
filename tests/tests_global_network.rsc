# global network

## ToIPPrefix

### positive
{
    $Print [$ToIPPrefix "1.1.1.1"];
    $Print [$ToIPPrefix "1.1.1.1/32"];
}

### negative
{
    $Print [$ToIPPrefix "1.1.1.256/32"];
    $Print [$ToIPPrefix "1.1.1/32"];
    $Print [$ToIPPrefix "1.1.1.1.1/32"];
}

## ParseCIDR
{
    $Print [$ParseCIDR "1.1.1.1/24"]; 
    $Print [$ParseCIDR "1.1.1.1/31"]; 
    $Print [$ParseCIDR "1.1.1.1"]; 
}


## GetPool
{
    :put [$GetIPPool [$ParseCIDR "1.1.1.1/24"] 100 199];
}
