# rspm

## register

### register exists

{
    :local pkg "rspm";
    [[$GetFunc "rspm.register"] Package=$pkg];
}


{
    :local pkg "my.wiz";
    [[$GetFunc "rspm.register"] Package=$pkg];
}

{
    :local pkg "my.wiz";
    [[$GetFunc "rspm.state.checkState"] Package=$pkg];
}

{
    :local pkg "my.wiz";
    :local va {"type"="code"};
    $GetMetaSafe $pkg VA=$va;
}