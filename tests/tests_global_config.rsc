## GetConfig
$Print [$GetConfig "config.rospm"];

## create config, check env

{
	:local config {
		"environment"={
			"Test1"="dwadawdf";
			"Test2"=12314;
			"Test3"=1.1.1.1;
		};
	};
	[$CreateConfig "config.test" $config \
		Description="some description" Owner="sbd" Force=true];
	$PrintGlobalEnv;
}

## update config, check env

{
	:local config {
		"environment"={
			"Test1"="ddddd";
			"Test2"=12314;
			"TestA"=114.114.114.114;
		};
	};
	[$UpdateConfig "config.test" $config];
	$PrintGlobalEnv;
	$Print $EnvTest1;
}

## remove config, check env

{
	[$RemoveConfig "config.test"];
	$PrintGlobalEnv;
}
