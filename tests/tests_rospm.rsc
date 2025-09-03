# rospm

## firstRun
{
	:local config {
		"baseURL"="https://raw.githubusercontent.com/Detavern/rospm/master/";
		"owner"="rospm";
	}
	[[$GetFunc "rospm.firstRun"] Context=$config];
}

## update
[[$GetFunc "rospm.update"]];

## upgrade
[[$GetFunc "rospm.upgrade"] Package="rospm"];
[[$GetFunc "rospm.upgrade"] Package="rospm.hello-world"];

## register local package

### register exists

{
	:local pkg "rospm";
	[[$GetFunc "rospm.register"] Package=$pkg];
}


## load global env

{
	:local configName "config.rospm.package";
	:local config [$GetConfig $configName];
	[$LoadGlobalEnv $configName ($config->"environment")];
}


# rospm.state

## check version
[[$GetFunc "rospm.state.checkVersion"] ForceUpdate=true];

## checkState
$Print [[$GetFunc "rospm.state.checkState"] Package="rospm"];
$Print [[$GetFunc "rospm.state.checkState"] Package="notexist"];
