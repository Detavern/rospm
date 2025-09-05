# rospm dev

## default branch
{
	:global EnvROSPMBaseURL "https://raw.githubusercontent.com/Detavern/rospm/master/";
}

## update to another branch
# first update config_package & env
{
	:local envConfig ([$GetConfig "config.rospm.package"]->"environment");
	:local branch [$InputV ("Enter branch name to switch to (e.g., master, dev, ...): ")];
	:local baseURL "https://raw.githubusercontent.com/Detavern/rospm/$branch/";
	:set ($envConfig->"ROSPMBaseURL") $baseURL;
	:set ($envConfig->"ROSPMBranch") $branch;
	[$UpdateConfig "config.rospm.package" ({"environment"=$envConfig})];
}


## register package
{
	[[$GetFunc "rospm.register"] Package="rospm"]
}
