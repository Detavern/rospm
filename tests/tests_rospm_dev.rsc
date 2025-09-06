# rospm dev

## turn off cache
{
	:local envConfig ([$GetConfig "config.rospm"]->"environment");
	:set ($envConfig->"GlobalCacheFuncEnabled") false;
	[$UpdateConfig "config.rospm" ({"environment"=$envConfig})];
}

## get rospm package configurations
{
	$Print [[$GetFunc "rospm.config.updatePackageConfig"]];
}

## update proxy
{
	:local context {"ROSPMProxy"="https://ghfast.top/"};
	$Print [[$GetFunc "rospm.config.updatePackageConfig"] Context=$context];
}

## reset version
{
	:local context {"ROSPMVersion"="0.5.3"};
	$Print [[$GetFunc "rospm.config.updatePackageConfig"] Context=$context];
}

## update to another branch

### first update config_package & env
{
	:local branch [$InputV ("Enter branch name to switch to (e.g., master, dev, ...): ")];
	:local context {"ROSPMBranch"=$branch};
	$Print [[$GetFunc "rospm.config.updatePackageConfig"] Context=$context];
}

### update && upgrade
{
	[[$GetFunc "rospm.update"]];
	$Print [[$GetFunc "rospm.state.checkAllState"]];
	[[$GetFunc "rospm.upgradeAll"]];
}


## register package
{
	[[$GetFunc "rospm.register"] Package="rospm"]
}
