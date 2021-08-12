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

#### `$InKeys` & `$InValues`

```
[admin@MikroTik] > {
    # InKeys
    :local v {
        "foo"="vf";
        "bar"="vb";
    };
    $Print [$InKeys "foo" $v];
    $Print [$InValues "vb" $v];
}

Type  : bool
Value : true
Type  : bool
Value : true
```

#### `$Assert`

```
[admin@MikroTik] > {
    :local v {
        "foo"="vf";
        "bar"="vb";
    };
    $Assert [$InKeys "foo" $v];
    $Assert [$InValues "value not exist" $v] "value not found";
}

Assert error: value not found
```

#### `$InputV`

Load value into the variable from terminal interactively.

```
# $InputV
# args: <str>                   info
# opt args: <str>               answer
# return: <var>                 recovered value

[admin@MikroTik] > {
    :local v [$InputV "Please enter an ip address"];
    # Enter an ip address from terminal, like 1.1.1.1
    $Print $v;
}

Please enter an ip address
value: 1.1.1.1

Type  : ip
Value : 1.1.1.1
```

### String Operations

#### `$Replace`

```
# $Replace
# args: <str>                   string
# args: <str>                   old
# args: <str>                   new
# return: <str>                 string replaced

[admin@MikroTik] > $Print [$Replace "hello world" "world" "Alice"];

Type  : str
Value : hello Alice
```

#### `$Split`

```
# $Split
# args: <str>                   target string
# args: <str>                   sub string
# opt args: <num>               split count
# return: <array>               array

[admin@MikroTik] > {
    $Print [$Split "a,b,c,d" ","];
    $Print [$Split "a,b,c,d" "," 1];
}

Type  : array
Key 0: a
Key 1: b
Key 2: c
Key 3: d

Type  : array
Key 0: a
Key 1: b,c,d
```

#### `$RSplit`

```
# $RSplit
# args: <str>                   target string
# args: <str>                   sub string
# opt args: <num>               split count
# return: <array>               array

[admin@MikroTik] > {
    $Print [$RSplit "a,b,c,d" ","];
    $Print [$RSplit "a,b,c,d" "," 1];
}

Type  : array
Key 0: a
Key 1: b
Key 2: c
Key 3: d

Type  : array
Key 0: a,b,c
Key 1: d
```

#### `$StartsWith` & `$EndsWith`

```
# $StartsWith / $EndsWith
# args: <str>                   target string
# args: <str>                   sub string
# return: <bool>                true or not

[admin@MikroTik] > {
    $Print [$StartsWith "hello world" "hello"];
    $Print [$EndsWith "hello world" "world"];
}

Type  : bool
Value : true
Type  : bool
Value : true
```

#### `$Strip`

```
# $Strip
# args: <str>                   target string
# opt args: <str>               characters to be removed
# opt kwargs: Mode=<str>        mode: b(both,default), l(left), r(right)
# return: <str>                 stripped string

[admin@MikroTik] > {
    $Print [$Strip ("  \r\nhello world  \t  ")];
    $Print [$Strip ("hello world") "hed"];
    $Print [$Strip ("hello world") "hed" Mode="l"];
    $Print [$Strip ("hello world") "hed" Mode="r"];
}

Type  : str
Value : hello world

Type  : str
Value : llo worl

Type  : str
Value : llo world

Type  : str
Value : hello worl
```

#### `$Join`

```
# $Join
# args: <str>                   separator
# args: <array>                 array of concatenation
# return: <str>                 result

[admin@MikroTik] > {
    :local a {"a";"b";"c";"d";"e"};
    $Print [$Join "," $a];
}

Type  : str
Value : a,b,c,d,e
```

### Datetime Operations

We will take an useful example of scheduler to explore these operations.

Suppose you want to execute a script 1 week after current time.

**At first, we need to know current time.**
```
[admin@MikroTik] > :put [$GetCurrentDatetime ];

2021;8;11;19;29;35
```

Then you get `2021;8;11;19;29;35` as the result,
it is an array of current date & time.
You can call it a `datetime` array.

`datetime` format:
`<year>;<month>;<day>;<hour>;<minute>;<second>`

Each of its elements is `num` type. 

**Second, we need to adjust the datetime array one week forward:**

```
[admin@MikroTik] > {
    # current time
    :local t [$GetCurrentDatetime ];
    # make a timedelta of 1 week
    :local timedelta {"days"=7};
    # calc the shift
    :put [$ShiftDatetime $t $timedelta];
}

2021;8;18;19;29;35
```

Here we defined a `timedelta` array with key `days`,
you can also use other available keys such as `years`, `months`, `hours`, `minutes` and `seconds`.
Their value can be positive or negative.

Have a look at `/system scheduler add`, you can notice that new schedule use `start-date` and `start-time` to determine the final execute time.

**Therefore, we need to convert our shifted `datetime` into some struct that scheduler can use.**

```
[admin@MikroTik] > {
    :local t [$GetCurrentDatetime ];
    :local timedelta {"days"=7};
    :local shifted [$ShiftDatetime $t $timedelta];
    # convert into SDT (Abbr. SDT, system datetime)
    $Print [$GetSDT $shifted];
}

Type  : array
Key date: aug/18/2021
Key time: 19:29:35
```

**Finally we could create our new schedule:**

```
[admin@MikroTik] > {
    :local t [$GetCurrentDatetime ];
    :local timedelta {"days"=7};
    :local shifted [$ShiftDatetime $t $timedelta];
    :local sdt [$GetSDT $shifted];
    # schedule
    /system scheduler add name="example" start-time=($sdt->"time") start-date=($sdt->"date") on-event=":put \"do sth\";"
}
```
#### Data Structure

```
# <SDT> array (system datetime)
{
    "date"=<str>;       # "aug/18/2021"
    "time"=<time>;      # 20:10:10
}

# <datetime> array
{
    <year>;             # num, calender year
    <month>;            # num, calendar month 1-12
    <day>;              # num, calendar date according to the month
    <hour>;             # num, 0-23
    <minute>;           # num, 0-59
    <second>;           # num, 0-59
}

# <timedelta> array
{
    "years"=<num>;
    "months"=<num>;
    "days"=<num>;
    "hours"=<num>;
    "minutes"=<num>;
    "seconds"=<num>;
}
```

#### `$IsSDT`
```
[admin@MikroTik] > {
    :local v [/system clock print as-value];
    $Print [$IsSDT $v];
    :local v {"date"="aug/8/2021";"time"=00:00:00};
    $Print [$IsSDT $v];
}

Type  : bool
Value : true
Type  : bool
Value : true
```

#### `$IsDatetime`
```
[admin@MikroTik] > {
    :local v {2021; 8; 12; 0; 0; 0};
    $Print [$IsDatetime $v];
    :local v {2021; 2; 30; 0; 0; 0};
    $Print [$IsDatetime $v];
}

Type  : bool
Value : true
Type  : bool
Value : false
```

#### `$IsTimeDelta`
```
[admin@MikroTik] > {
    :local v {"days"=-100};
    $Print [$IsTimeDelta $v];
    :local v {"dayss"=-1};
    $Print [$IsTimeDelta $v];
}

Type  : bool
Value : true
Type  : bool
Value : false
```

#### `$IsLeapYear`
```
[admin@MikroTik] > {
    $Print [$IsLeapYear 2020];
    $Print [$IsLeapYear 2021];
}

Type  : bool
Value : true
Type  : bool
Value : false
```

#### `$GetCurrentClock`
```
# $GetCurrentClock
# get current info from system clock
# same as [/system clock print as-value]
# return: <str>                 clock info array

[admin@MikroTik] > $Print [$GetCurrentClock ];

Type  : array
Key date: aug/11/2021
Key dst-active: false
Key gmt-offset: 0
Key time: 20:00:00
Key time-zone-autodetect: true
Key time-zone-name: UTC
```

#### `$GetCurrentSDT`
```
# $GetCurrentSDT
# get current SDT from system clock
# return: <array>               SDT array

[admin@MikroTik] > $Print [$GetCurrentSDT ];

Type  : array
Key date: aug/11/2021
Key time: 20:00:00
```

#### `$GetCurrentDatetime`
```
# $GetCurrentDatetime
# get current datetime from system clock
# return: <array>               datetime array

[admin@MikroTik] > :put [$GetCurrentDatetime ];

2021;8;11;20;00;00
```

#### `$GetSDT`
```
# $GetSDT
# args: <var>                   <datetime>
# return: <sdt>                 array of sdt

[admin@MikroTik] > $Print [$GetSDT [$GetCurrentDatetime ]];

Type  : array
Key date: aug/11/2021
Key time: 20:00:00
```

#### `$GetDatetime`
```
# $GetDatetime
# args: <var>                   <sdt>
# return: <datetime>            datetime

[admin@MikroTik] > :put [$GetDatetime [$GetCurrentSDT ]];

2021;8;11;20;00;00
```

#### `$GetFullTimedelta`
```
# $GetFullTimedelta
# return a full timedelta array from timedelta or time
# args: <time>/<timedelta>      time or timedelta
# return: <array>               timedelta array

[admin@MikroTik] > {
    :local v 3w100d10:10:10;
    $Print [$GetFullTimedelta $v];
    :local v {"days"=-100; "months"=12};
    $Print [$GetFullTimedelta $v];
}

Type  : array
Key days: 121
Key hours: 10
Key minutes: 10
Key months: 0
Key seconds: 10
Key years: 0

Type  : array
Key days: -100
Key hours: 0
Key minutes: 0
Key months: 12
Key seconds: 0
Key years: 0
```

#### `$ShiftDatetime`
```
# $ShiftDatetime
# datetime shift
# args: <datetime>              array of datetime
# args: <time>/<timedelta>      time or timedelta
# return: <array>               shifted datetime

[admin@MikroTik] > {
    :local dt {2021;8;11;20;00;00};
    :local td {"days"=-10000};
    :local shifted [$ShiftDatetime $dt $td];
    :put $shifted;
    :local t -10000d;
    :local shifted [$ShiftDatetime $dt $t];
    :put $shifted;
}

1994;3;26;20;00;00
1994;3;26;20;00;00

[admin@MikroTik] > {
    :local dt {2021;8;11;20;00;00};
    :local td {"seconds"=10000000};
    :local shifted [$ShiftDatetime $dt $td];
    :put $shifted;
    :local t 00:00:10000000;
    :local shifted [$ShiftDatetime $dt $t];
    :put $shifted;
}

2021;12;5;13;46;40
2021;12;5;13;46;40
```

When you use `months` key in `timedelta`, do realize that it may cause the change of date:

```
[admin@MikroTik] > {
    :local dt {2021;8;31;20;00;00};
    :local td {"months"=18};
    :local shifted [$ShiftDatetime $dt $td];
    :put $shifted;
    :local td {"months"=-18};
    :local shifted [$ShiftDatetime $dt $td];
    :put $shifted;
}

2023;2;28;20;0;0
2020;2;29;20;0;0
```

### Array Operations

