# RouterOS Script Package Manager

## alpha version *(for test only, no warranty)*

RSPM is a package manager for RouterOS script.
You can use RSPM to install and share script packages.

AS A PLUS, RSPM also provide many useful script packages for RouterOS,
which support RSPM itself and fulfill the missing
`string` operation, `datetime` operation and so on.

All RSPM packages and configurations will store locally
in you script repository(`/system script`) and keep working after reboot.

The main propose of this project is
to help you conveniently write and organize your script.

## Requirements

RouterOS 6.47+

## Installation

Open the RouterOS terminal, copy & paste the following and run:
```
/tool fetch url="https://raw.githubusercontent.com/Detavern/rspm/master/rspm-installer.rsc"; /import rspm-installer.rsc;
```

## Getting Started

### Concept

- package: every script file with proper `metaInfo` defined in it, take the [Example Package hello world](https://github.com/Detavern/rspm-pkg-hello-world) at a glance. 

There are two kinds of packages, the `core package` and `extension package`.

- `Core packages` are those packages from this repository.
- `Extension packages` are thoses packages installed via third-party URL.

### Install a package

Taking [Example Package hello world](https://github.com/Detavern/rspm-pkg-hello-world) as an example, installing via raw script file's URL:
```
[[$GetFunc "rspm.install"] URL="https://raw.githubusercontent.com/Detavern/rspm-pkg-hello-world/master/hello-world.rsc"];
```

Now you can invoke the `helloWorld` functions in that package:
```
[[$GetFunc "rspm.hello-world.helloWorld"] ];
```

Try passing a parameter into the function:
```
[[$GetFunc "rspm.hello-world.helloWorld"] Name="Bob"];
```

### Update the package list

You can use this command to check the package list.
```
[[$GetFunc "rspm.update"] ];
```
It will tell you how many packages need upgrade.
It is recommended to invoke this function before upgrading.
(just like `apt update`)

### Upgrade the package

Use this command to upgrade specific package.
```
[[$GetFunc "rspm.upgrade"] Package="rspm.hello-world"];
```

You may notice here we start to use the package name `rspm.hello-world`.
And yes, after installation,all interactions with packages are done via package name.

Or you can use this command to check and upgrade all packages.
```
[[$GetFunc "rspm.upgradeAll"] ];
```

### Remove installed package

You can use this command to remove installed package.
```
[[$GetFunc "rspm.remove"] Package="rspm.hello-world"];
```

### Reinstall package

If you once had installed some `extension packages` via URL and removed it later.
And now, you want to install it again.
You can use package name to install it directly,
since the `metaInfo` is already written into local configurations.

Take `rspm.hello-world` as an example.
```
[[$GetFunc "rspm.install"] Package="rspm.hello-world"];
```

### Register manually added package

Under some circumstances, you may need to register local added packages.
Take [Example Package hello world](https://github.com/Detavern/rspm-pkg-hello-world) as an example:

- First, open `winbox` -> `system` -> `script`.
- Add a new script, its name should be `rspm_hello-world`
(Replace package name's "." with "_").
- Copy and paste all content from file `hello-world.rsc` into source form.
- Press OK, now local package is added.

Register use following command:

```
[[$GetFunc "rspm.register"] Package="rspm.hello-world"];
```

## Global Variables

There are many global variables which will be loaded automatically when startup,
that you can use when writing your own script.

**DO NOT CORRUPT any value of those UNLESS you know what you are doing, otherwise the tiny world will be ruined.**

I will not list global variables here,
you can take a look at [/lib/global-variables.rsc](https://github.com/Detavern/rspm/blob/master/lib/global-variables.rsc) for detail.

## Global Functions

### Common Operations

#### `$Print`

Your dearest friend, not only print value by also its type:

```
[admin@MikroTik] > $Print 1      
Type  : str
Value : 1
```

You may notice here it mentions the type of `1` is `str`.

You will get `num` if using vanilla command `:put [:typeof 1];`.

It is not an error, but how the vanilla script's function works!
It seems all values passing into the function without
explicit variable will be interpretered into `str` type!

Using explicit variables and you will get the right answer:
```
[admin@MikroTik] > :local v 1;$Print $v;
Type  : num
Value : 1
```

However, there is some trick to bypassing it:
```
[admin@MikroTik] > $Print (1)
Type  : num
Value : 1

[admin@MikroTik] > $Print [$TypeRecovery 1];
Type  : num
Value : 1
```

#### `$IsNothing`

```
[admin@MikroTik] > {
    :local v;
    $Print [$IsNothing $v];

    :local v ([$NewArray]->"key not exist");
    $Print [$IsNothing $v];    
}

Type  : bool
Value : true
Type  : bool
Value : true
```

#### `$IsNil`

```
[admin@MikroTik] > {
    :local v [find "" "a"];
    $Print [$IsNil $v];

    :local v [$FuncNotExist ];
    $Print [$IsNil $v];
}

Type  : bool
Value : true
Type  : bool
Value : true
```

#### `$Is<Type>`

```
[admin@MikroTik] > {
    # IsStr
    :local v "foo";
    $Print [$IsStr $v];
    # IsNum
    :local v 100;
    $Print [$IsNum $v];
    # IsIP
    :local v 1.1.1.1;
    $Print [$IsIP $v];
    # IsTime
    :local v 1w3d00:00:00;
    $Print [$IsTime $v];
    # Is Bool; IsIPPrefix; IsIPv6; IsIPv6Prefix; IsArray;
}

Type  : bool
Value : true
...
...
```

#### `$Is<Type>`


### String Operations

### Datetime Operations

### Array Operations

