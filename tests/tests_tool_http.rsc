# tool

## headers
{
	:local pHeaders {
		"Accept"="application/json";
	}
	:put [[$GetFunc "tool.http.makeHeaders"] Headers=$pHeaders];
}

## raw fetch
{
	:local pHeaders {
		"Accept"="application/json";
	}
	:local headers [[$GetFunc "tool.http.makeHeaders"] Headers=$pHeaders];
	:local urlStr "http://127.0.0.1:8000/api/v1/health";
	:local resp [/tool/fetch url=$urlStr http-header-field=$headers output="user" as-value]
	:put $resp;
}

## http get
{
	:put [[$GetFunc "tool.http.httpGet"]
		URL="https://raw.githubusercontent.com/Detavern/rospm/master/rospm-installer.rsc"];
	$Print [[$GetFunc "tool.http.httpGet"]
		URL="https://raw.githubusercontent.com/Detavern/rospm/master/res/package-info.rsc"];
}

## http post
{
	:local url "http://127.0.0.1:8000/api/v1/health"
	:local pData {
		"ip"=1.2.3.4;
		"token"="foobar";
	}
	:local resp [[$GetFunc "tool.http.httpPost"] URL=$url Data=$pData DataType="json" Output="json"];
	$Print $resp;
}
