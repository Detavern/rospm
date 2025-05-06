# rospm

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
