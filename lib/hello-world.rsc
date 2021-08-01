:local metaInfo {
    "name"="hello-world";
    "version"="0.0.1";
    "description"="hello world package";
};

# [$helloWorld name='']
:local helloWorld do={
    #DEFINE global
    :global IsNothing;
    # check name
    :if ([$IsNothing $name]) do={
        :put "Hello world!";
    } else {
        :put ("Hello " . $name . "!");
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "helloWorld"=$helloWorld;
}
:return $package;
