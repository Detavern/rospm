## token challenge
{
    :local token "<enter cloudflare token here>"
    :put [[$GetFunc "ddns.provider.cloudflare.verifyToken"] Token=$token ];
}

## ensure host record
## suppose your target FQDN is test.ddns.example.com
{
    :local token "<enter cloudflare token here>"
    :local zoneName "<enter your zone name (example.com)>"
    :local recordName "<enter your record name, (test.ddns)>"
    :local ip 127.0.1.1;
    :local params {
        "token"=$token;
        "zoneName"=$zoneName;
        "recordName"=$recordName;
    };
    :local result [[$GetFunc "ddns.provider.cloudflare.ensureHostRecord"] IP=$ip Params=$params ];
    $Print $result;
}