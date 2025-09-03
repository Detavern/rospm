# tool/remote

## loadRemoteScript
{
	:local url "https://raw.githubusercontent.com/Detavern/rospm/master/res/startup.rsc";
	:local scriptStr [[$GetFunc "tool.remote.loadRemoteSource"] URL=$url Normalize=true];
	/system scheduler remove [/system scheduler find name="rospm-startup"];
	/system scheduler add name="rospm-startup" start-time=startup on-event=$scriptStr;
}
