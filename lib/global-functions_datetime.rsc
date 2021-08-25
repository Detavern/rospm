# Global Functions | Datetime
# =========================================================
# ALL global functions follows upper camel case.
# Global package for date and time.
#
# USE as your wish
#
# New structure
# <SDT> array (system datetime)
# {
#     "date"=<str>;
#     "time"=<time>;
# }
#
# <datetime> array
# {<year>; <month>; <day>; <hour>; <minute>; <second>}
# <year>      num, calender year
# <month>     num, calendar month 1-12
# <day>       num, calendar day
# <hour>      num, 0-23
# <minute>    num, 0-59
# <second>    num, 0-59
#
# <timedelta> array
# {
#     "seconds"=<num>;
#     "minutes"=<num>;
#     "hours"=<num>;
#     "days"=<num>;
#     "months"=<num>;
#     "years"=<num>;
# }

:local metaInfo {
    "name"="global-functions.datetime";
    "version"="0.1.0";
    "description"="global functions for datetime operation";
    "global"=true;
};


# $IsSDT
# args: <var>                   var
# return: <bool>                flag
:global IsSDT do={
    # global declare
    :global InKeys;
    :global TypeofArray;
    # check
    :if ([:typeof $1] != $TypeofArray) do={
        :return false;
    };
    :if (![$InKeys "date" $1]) do={
        :return false;
    }
    :if (![$InKeys "time" $1]) do={
        :return false;
    }
    :return true;
}


# $IsDatetime
# {<year>; <month>; <day>; <hour>; <minute>; <second>}
# args: <var>                   var
# return: <bool>                flag
:global IsDatetime do={
    # global declare
    :global IsNum;
    :global MonthsOfTheYear;
    # local
    :if ([:len $1] != 6) do={
        :return false;
    };
    :foreach k,v in $1 do={
        :if (![$IsNum $k] or ![$IsNum $v]) do={
            :return false;
        }
    }
    # month
    :local mm ($1->1);
    :if ($mm > 12 or $mm < 1) do={
        :return false;
    }
    # date
    :local mDays $MonthsOfTheYear;
    :local dd ($1->2);
    :local ddMax ($mDays->($mm - 1));
    :if ($dd > $ddMax or $dd < 1) do={
        :return false;
    }
    # hour
    :local HH ($1->3);
    :if ($HH > 23 or $HH < 0) do={
        :return false;
    }
    # minute
    :local MM ($1->4);
    :if ($MM > 59 or $MM < 0) do={
        :return false;
    }
    # minute
    :local SS ($1->5);
    :if ($SS > 59 or $SS < 0) do={
        :return false;
    }
    :return true;
}


# $IsTimeDelta
# args: <var>                   var
# return: <bool>                flag
:global IsTimeDelta do={
    # global declare
    :global InValues;
    :global IsNum;
    :global TypeofArray;
    # local
    :local nKeys {"seconds";"minutes";"hours";"days";"months";"years"};
    :if ([:typeof $1] != $TypeofArray) do={
        :return false;
    };
    :foreach k,v in $1 do={
        :if (![$InValues $k $nKeys]) do={
            :return false;
        }
        :if (![$IsNum $v]) do={
            :return false;
        }
    }
    :return true;
}


# $GetCurrentClock
# get current info from system clock
# return: <str>                 clock array
:global GetCurrentClock do={
    :local clock [/system clock print as-value];
    :return $clock;
}


# $GetCurrentDate
# get current date from system clock
# return: <str>                 date
:global GetCurrentDate do={
    :local clock [/system clock print as-value];
    :return ($clock->"date");
}


# $GetCurrentTime
# get current date from system clock
# return: <str>                 date
:global GetCurrentTime do={
    :local clock [/system clock print as-value];
    :return ($clock->"time");
}


# $GetCurrentSDT
# get current SDT from system clock
# return: <array>               SDT array
:global GetCurrentSDT do={
    :local clock [/system clock print as-value];
    :local dt {
        "time"=($clock->"time");
        "date"=($clock->"date");
    }
    :return $dt;
}


# $ToTimedelta
# return a full timedelta array from timedelta or time
# args: <time>/<timedelta>      time or timedelta
# return: <array>               timedelta array
:global ToTimedelta do={
    # global declare
    :global NewArray;
    :global IsNil;
    :global IsNothing;
    :global IsTime;
    :global IsTimeDelta;
    :global Split;
    # local
    :local td [$NewArray ];
    :set ($td->"seconds") 0;
    :set ($td->"minutes") 0;
    :set ($td->"hours") 0;
    :set ($td->"days") 0;
    :set ($td->"months") 0;
    :set ($td->"years") 0;
    :local flag false;
    :if ([$IsTime $1]) do={
        :set flag true;
        # parse
        :local stt [:tostr $1];
        :local first [:pick $stt 0 1];
        :local f 1;
        :if ($first = "-") do={
            :set stt [:pick $stt 1 [:len $stt]];
            :set f -1;
        }
        :local lenStt [:len $stt];
        :local tp [:pick $stt ($lenStt - 8) $lenStt];
        :local tpList [$Split $tp ":"];
        :set ($td->"hours") ([:tonum ($tpList->0)] * $f);
        :set ($td->"minutes") ([:tonum ($tpList->1)] * $f);
        :set ($td->"seconds") ([:tonum ($tpList->2)] * $f);
        :if ($lenStt > 8) do={
            :local wdp [:pick $stt 0 ($lenStt - 8)];
            :local days 0;
            :local findw [:find $wdp "w"];
            :if (![$IsNil $findw]) do={
                :local weeks [:tonum [:pick $wdp 0 $findw]];
                :set days ($days + (7 * $weeks));
                :set wdp [:pick $wdp ($findw + 1) [:len $wdp]];
            };
            :local findd [:find $wdp "d"];
            :if (![$IsNil $findw]) do={
                :local ds [:tonum [:pick $wdp 0 $findd]];
                :set days ($days + $ds);
            };
            :set ($td->"days") ($days * $f);
        }
    };
    :if ([$IsTimeDelta $1]) do={
        :set flag true;
        :foreach k,v in $1 do={
            :set ($td->$k) $v;
        }
    };
    :if ([$IsNothing $td]) do={
        :set flag true;
    };
    :if (!$flag) do={
        :error "Global.Datetime.ToTimedelta: \$1 should be time or timedelta or nil";
    }
    :return $td;
}


# $ToDatetime
# args: <var>                   <sdt>, <timestamp>
# return: <datetime>            datetime
:global ToDatetime do={
    # global declare
    :global IsSDT;
    :global IsNothing;
    :global Split;
    :global MonthsName;
    :global MonthsOfTheYear;
    # local
    :local dt $1;
    :local flag false;
    :if ([$IsSDT $dt]) do={
        :set flag true;
        # fact
        :local mDays $MonthsOfTheYear;
        :local mNames $MonthsName;
        # read mm dd yy
        :local mmddyy [$Split ($dt->"date") "/"];
        :local mmName ($mmddyy->0);
        :local dd [:tonum ($mmddyy->1)];
        :local yy [:tonum ($mmddyy->2)];
        :local mm;
        :foreach k,v in $mNames do={
            :if ($v = $mmName) do={
                :set mm ($k + 1);
            }
        }
        :if ([$IsNothing $mm]) do={
            :error "Global.Datetime.ToDatetime: Read mm error";
        };
        # read HH MM SS
        :local HHMMSS [$Split [:tostr ($dt->"time")] ":"];
        :local HH [:tonum ($HHMMSS->0)];
        :local MM [:tonum ($HHMMSS->1)];
        :local SS [:tonum ($HHMMSS->2)];
        :return {$yy; $mm; $dd; $HH; $MM; $SS};
    };
    # TODO: other type

    # error
    :if (!$flag) do={
        :error "Global.Datetime.ToDatetime: type not match";
    };
}


# $GetCurrentDatetime
# get current datetime from system clock
# return: <array>               datetime array
:global GetCurrentDatetime do={
    # global declare
    :global GetCurrentSDT;
    :global ToDatetime;
    # local
    :local sdt [$GetCurrentSDT ];
    :return [$ToDatetime $sdt];
}


# $ToSDT
# args: <var>                   <datetime>, <timestamp>
# return: <sdt>                 array of sdt
:global ToSDT do={
    # global declare
    :global IsDatetime;
    :global IsNothing;
    :global MonthsName;
    # local
    :local dt $1;
    :local flag false;
    :if ([$IsDatetime $dt]) do={
        :set flag true;
        # format
        :local H ($dt->3);
        :local M ($dt->4);
        :local S ($dt->5);
        :local hms [:totime "$H:$M:$S"];
        :local yy ($dt->0);
        :local mm ($dt->1);
        :local dd ($dt->2);
        :local nmm ($MonthsName->($mm - 1));
        :local ndd "$dd";
        :if ($dd < 10) do={
            :set ndd "0$dd";
        }
        :local ymd "$nmm/$ndd/$yy";
        :local result {
            "date"=$ymd;
            "time"=$hms;
        };
        :return $result;
    };
    # TODO: other type

    # error
    :if (!$flag) do={
        :error "Global.Datetime.ToSDT: type not match";
    };
}


# $IsLeapYear
# args: <num>               year
# return: <bool>            is leap year or not
:global IsLeapYear do={
    :local yy $1;
    :return (($yy % 4 = 0) and ($yy % 100 != 0) or ($yy % 400 = 0));
}


# $ShiftDatetime
# datetime shift
# args: <datetime>              array of datetime
# args: <time>/<timedelta>      time or timedelta
# return: <array>               shifted datetime
:global ShiftDatetime do={
    # global declare
    :global IsNothing;
    :global IsDatetime;
    :global TypeofTime;
    :global TypeofArray;
    :global ToTimedelta;
    :global IsLeapYear;
    :global MonthsOfTheYear;
    :global Split;
    # local
    :if (![$IsDatetime $1]) do={
        :error "Global.Datetime.ShiftDatetime: \$1 should be datetime";
    };
    :local dt $1;
    :local td [$ToTimedelta $2];
    # SS MM HH + only
    # SS
    :local SS;
    :local aMM;
    :local rSS (($dt->5) + ($td->"seconds"));
    :if ($rSS < 0) do={
        :set SS ($rSS % 60 + 60);
        :set aMM ($rSS / 60 - 1);
    } else {
        :set SS ($rSS % 60);
        :set aMM ($rSS / 60);
    }
    # MM
    :local MM;
    :local aHH;
    :local rMM (($dt->4) + ($td->"minutes") + $aMM);
    :if ($rMM < 0) do={
        :set MM ($rMM % 60 + 60);
        :set aHH ($rMM / 60 - 1);
    } else {
        :set MM ($rMM % 60);
        :set aHH ($rMM / 60);
    }
    # HH
    :local HH;
    :local add;
    :local rHH (($dt->3) + ($td->"hours") + $aHH);
    :if ($rHH < 0) do={
        :set HH ($rHH % 24 + 24);
        :set add ($rHH / 24 - 1);
    } else {
        :set HH ($rHH % 24);
        :set add ($rHH / 24);
    }
    # dd mm yy +/-
    # dd
    :local rmm ($dt->1);
    :local ryy ($dt->0);
    :local rdd (($dt->2) + ($td->"days") + $add);
    :local ddMax;
    :local ddYMax;
    :local flagdd true;
    :while ($flagdd) do={
        # TODO: skip year
        # skip month
        :if ($rdd > 0) do={
            :set ddMax ($MonthsOfTheYear->($rmm - 1));
            :if ([$IsLeapYear $ryy]) do={
                :if ($rmm = 2) do={
                    :set ddMax ($ddMax + 1);
                }
            }
            :if ($rdd > $ddMax) do={
                :set rdd ($rdd - $ddMax);
                :set rmm ($rmm + 1);
                :if ($rmm > 12) do={
                    :set rmm 1;
                    :set ryy ($ryy + 1);
                };
            } else {
                :set flagdd false;
            }
        } else {
            :set rmm ($rmm - 1);
            :if ($rmm < 0) do={
                :set rmm 12;
                :set ryy ($ryy - 1);
            };
            :set ddMax ($MonthsOfTheYear->($rmm - 1));
            :if ([$IsLeapYear $ryy]) do={
                :if ($rmm = 2) do={
                    :set ddMax ($ddMax + 1);
                }
            }
            :set rdd ($rdd + $ddMax);
        }
    };
    :local dd $rdd;
    # mm
    :local ayy 0;
    :local mm ($rmm + ($td->"months"));
    :if ($mm > 0) do={
        :if ($mm > 12) do={
            :set ayy ($mm / 12);
            :set mm ($mm % 12);
        }
    } else {
        :set ayy (($mm / 12) - 1);
        :set mm (($mm % 12) + 12);
    }
    # yy
    :local yy ($ryy + ($td->"years") + $ayy);
    # trim dd by mm
    :set ddMax ($MonthsOfTheYear->($mm - 1));
    :if (($mm = 2) and [$IsLeapYear $yy]) do={
        :set ddMax ($ddMax + 1);
    }
    :if ($dd > $ddMax) do={
        :set dd $ddMax;
    }
    # return
    :local result {$yy; $mm; $dd; $HH; $MM; $SS};
    :return $result;
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
