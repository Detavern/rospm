# global datetime

## ToTimedelta
{
    :local t1 240:0:0;
    :local t2 0:30:0;
    :put ($t1 - $t2);
    :put [$ToTimedelta ($t1 - $t2)];
    :put ($t2 - $t1);
    :put [$ToTimedelta ($t2 - $t1)];
}

## ToSDT
{
    :local dt {2020;10;9;8;7;6};
    $Print [$ToSDT $dt];
}
### error example
{
    :local dt {2020;10;9;8;7;60};
    $Print [$ToSDT $dt];
}

## datetimeshift
{
    :local cdt {2020;1;2;16;37;21};
    :put $cdt;
    :local td 1577w5d11:14:40;
    :put [$ShiftDatetime $cdt $td ];
}
{
    :local cdt [$GetCurrentDatetime ];
    :put $cdt;
    :local td {"days"=10000};
    :put [$ShiftDatetime $cdt $td ];
}

## GetTimeDiff
{
    :local adt {2020;1;2;16;37;21};
    :local bdt {2050;3;30;3;52;1};
    :put [$GetTimeDiff $adt $bdt];
}

{
    :local adt {2020;1;2;16;37;21};
    :local bdt {2050;3;30;3;52;1};
    :local timeDiff [$GetTimeDiff $bdt $adt];
    :put $timeDiff;
}

## GetTimedeltaDiff

{
    :local adt {2020;1;2;16;37;21};
    :local bdt {2050;3;30;3;52;1};
    :local timeDiff [$GetTimedelta $bdt $adt];
    :put [$ToTimedelta $timeDiff];
}
