#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.datetime
# ===================================================================
# ALL global functions follows upper camel case.
# Global functions are designed to perform datetime calcuation.
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
# New structure
# <SDT> array (system datetime)
# {
#     "date"="YYYY-MM-DD";
#     "time"=<time>;
# }
#
# <Datetime> array
# {<year>; <month>; <day>; <hour>; <minute>; <second>}
# <year>      num, calender year
# <month>     num, calendar month 1-12
# <day>       num, calendar day
# <hour>      num, 0-23
# <minute>    num, 0-59
# <second>    num, 0-59
#
# <Timedelta> array
# {
#     "seconds"=<num>;
#     "minutes"=<num>;
#     "hours"=<num>;
#     "days"=<num>;
#     "months"=<num>;
#     "years"=<num>;
# }
# NOTE: <Timedelta> array may not be complete.
# An array contains any sort of keys above will be recognized as a valid <Timedelta> array.
#
:local metaInfo {
    "name"="global-functions.datetime";
    "version"="0.5.1";
    "description"="Global functions are designed to perform datetime calcuation.";
    "global"=true;
    "global-functions"={
        "IsSDT";
        "IsDatetime";
        "IsTimedelta";
        "GetCurrentDate";
        "GetCurrentTime";
        "GetCurrentSDT";
        "ToTimedelta";
        "ToDatetime";
        "GetCurrentDatetime";
        "ToSDT";
        "IsLeapYear";
        "ShiftDatetime";
        "CompareDatetime";
        "GetTimeDiff";
        "GetTimedeltaDiff";
    };
};


# $IsSDT
# args: <var>                   var
# return: <bool>                flag
:global IsSDT do={
    # global declare
    :global IsArrayN;
    :global GetKeys;
    :global IsSubset;
    # check
    :if (![$IsArrayN $1]) do={
        :return false;
    };
    # check keys
    :local validator {
        "date";"time";
    }
    :return [$IsSubset $validator [$GetKeys $1]];
}


# $IsDatetime
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


# $IsTimedelta
# args: <var>                   var
# return: <bool>                flag
:global IsTimedelta do={
    # global declare
    :global IsArrayN;
    :global GetKeys;
    :global IsSubset;
    # local
    :if (![$IsArrayN $1]) do={
        :return false;
    };
    # check
    :local validator {"seconds";"minutes";"hours";"days";"months";"years"};
    :return [$IsSubset [$GetKeys $1] $validator];
}


# $GetCurrentDate
# Get current date from system clock. There are two types of format now:
# jan/02/1970 or 1970-01-02, and the first type will be choose.
# return: <str>                 date
:global GetCurrentDate do={
    # global declare
    :global Split;
    :global MonthsName;
    # local
    :local date ([/system/clock/print as-value]->"date");
    :if ($date~"^\\w+/\\d+/\\d+\$") do={
        :return $date;
    }
    :if ($date~"^\\d+-\\d+-\\d+\$") do={
        # convert 1970-01-02 to jan/02/1970
        :local yymmdd [$Split $date "-"];
        :local yy [:tonum ($yymmdd->0)];
        :local mm [:tonum ($yymmdd->1)];
        :local dd [:tonum ($yymmdd->2)];
        :local mmName ($MonthsName->($mm - 1));
        :return "$mmName/$dd/$yy";
    }
    # raise if unknown format
    :error "Global.Datetime.GetCurrentDate: unknown format of date $date, report to the developer!";
}


# $GetCurrentTime
# Get current date from system clock.
# return: <time>                current time
:global GetCurrentTime do={
    :local clock [/system/clock/print as-value];
    :return ($clock->"time");
}


# $GetCurrentSDT
# Get current SDT from system clock.
# return: <SDT>                 SDT array
:global GetCurrentSDT do={
    # global declare
    :global GetCurrentDate;
    # local
    :local clock [/system/clock/print as-value];
    :local dt {
        "time"=($clock->"time");
        "date"=[$GetCurrentDate ];
    }
    :return $dt;
}


# $ToTimedelta
# Return a complete timedelta array from timedelta or time.
# args: <time> or <Timedelta>       time or timedelta
# return: <Timedelta>               complete timedelta array
:global ToTimedelta do={
    # global declare
    :global NewArray;
    :global IsNil;
    :global IsNothing;
    :global IsTime;
    :global IsTimedelta;
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
    :if ([$IsTimedelta $1]) do={
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
# Convert a SDT array to a datetime array.
# args: <var>                   <SDT>
# return: <Datetime>            datetime array
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
    # NOTE: add other type here
    # error
    :if (!$flag) do={
        :error "Global.Datetime.ToDatetime: type not match";
    };
}


# $GetCurrentDatetime
# Get current datetime from system clock.
# return: <Datetime>            datetime array
:global GetCurrentDatetime do={
    # global declare
    :global GetCurrentSDT;
    :global ToDatetime;
    # local
    :local sdt [$GetCurrentSDT ];
    :return [$ToDatetime $sdt];
}


# $ToSDT
# Convert a datetime array to a SDT array.
# args: <var>                   <Datetime>
# return: <SDT>                 SDT array
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
    # NOTE: add other type here
    # error
    :if (!$flag) do={
        :error "Global.Datetime.ToSDT: type not match";
    };
}


# $IsLeapYear
# Determine whether the input year is a leap year.
# args: <num>               year
# return: <bool>            is leap year or not
:global IsLeapYear do={
    :local yy $1;
    :return (($yy % 4 = 0) and ($yy % 100 != 0) or ($yy % 400 = 0));
}


# $ShiftDatetime
# Return a new datetime array by shifting a datetime array with time or timedelta. 
# args: <Datetime>                  datetime array
# args: <time> or <Timedelta>       time or timedelta
# return: <Datetime>                shifted datetime array
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
    # check
    :if (![$IsDatetime $1]) do={:error "Global.Datetime.ShiftDatetime: \$1 should be datetime"};
    # local
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
    :local ryy ($dt->0);
    :local rmm ($dt->1);
    :local rdd (($dt->2) + ($td->"days") + $add);
    :local ddMax;
    :local ddYMax;
    :local flagdd true;
    :while ($flagdd) do={
        :set ddYMax 365;
        :if ($rdd > 0) do={
            # calc days of year
            :if (($rmm <= 2) and [$IsLeapYear $ryy]) do={:set ddYMax 366};
            :if (($rmm > 2) and [$IsLeapYear ($ryy + 1)]) do={:set ddYMax 366};
            # try skip by year
            :if ($rdd > $ddYMax) do={
                :set rdd ($rdd - $ddYMax);
                :set ryy ($ryy + 1);
            } else {
                # calc days of month
                :set ddMax ($MonthsOfTheYear->($rmm - 1));
                :if (($rmm = 2) and [$IsLeapYear $ryy]) do={:set ddMax 29};
                # try skip by month
                :if ($rdd > $ddMax) do={
                    :set rdd ($rdd - $ddMax);
                    :set rmm ($rmm + 1);
                    :if ($rmm > 12) do={
                        :set rmm 1;
                        :set ryy ($ryy + 1);
                    };
                } else {
                    # skip finish
                    :set flagdd false;
                }
            }
        } else {
            # calc days of year
            :if (($rmm <= 2) and [$IsLeapYear ($ryy - 1)]) do={:set ddYMax 366};
            :if (($rmm > 2) and [$IsLeapYear $ryy]) do={:set ddYMax 366};
            # try skip by year
            :if (($rdd + $ddYMax) < 0) do={
                :set rdd ($rdd + $ddYMax);
                :set ryy ($ryy - 1);
            } else {
                # skip month
                :set rmm ($rmm - 1);
                :if ($rmm < 1) do={:set rmm 12;}
                :set ddMax ($MonthsOfTheYear->($rmm - 1));
                :if (($rmm = 2) and [$IsLeapYear $ryy]) do={:set ddMax 29};
                :set rdd ($rdd + $ddMax);
            }
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


# $CompareDatetime
# Return a number that indicate which datetime array of two inputs is later,
# return zero if same. 
# args: <Datetime>              datetime
# args: <Datetime>              datetime
# return: <num>                 1: $1 > $2, -1: $1 < $2, 0: same
:global CompareDatetime do={
    # global declare
    :global IsNothing;
    :global IsDatetime;
    # check
    :if (![$IsDatetime $1]) do={:error "Global.Datetime.CompareDatetime: \$1 should be datetime"};
    :if (![$IsDatetime $2]) do={:error "Global.Datetime.CompareDatetime: \$2 should be datetime"};
    # local
    :local cursor 0;
    :local a;
    :local b;
    :while ($cursor < [:len $1]) do={
        :set a ($1->$cursor);
        :set b ($2->$cursor);
        :if ($a > $b) do={:return 1};
        :if ($a < $b) do={:return -1};
        :set cursor ($cursor + 1);
    }
    :return 0;
}


# $GetTimeDiff
# Return a time value that represents the difference of two datetime arrays.
# The value is positive if the first datetime array ($1) is earlier.
# args: <Datetime>              start point datetime array
# args: <Datetime>              end point datetime array
# return: <time>                the difference of two datetime arrays
:global GetTimeDiff do={
    # global declare
    :global IsNil;
    :global NewArray;
    :global IsDatetime;
    :global IsLeapYear;
    :global MonthsOfTheYear;
    :global CompareDatetime;
    # check
    :if (![$IsDatetime $1]) do={:error "Global.Datetime.GetTimeDiff: \$1 should be datetime"};
    :if (![$IsDatetime $2]) do={:error "Global.Datetime.GetTimeDiff: \$2 should be datetime"};
    # ensure adt earlier than bdt
    :local adt $1;
    :local bdt $2;
    :local sign "";
    :local cmp [$CompareDatetime $1 $2]
    :if ($cmp = 0) do={:return 00:00:00};
    :if ($cmp > 0) do={
        :set adt $2;
        :set bdt $1;
        :set sign "-";
    }
    # A: 2020, 2, 2, 6, 14, 17
    # B: 2022, 8, 31, 6, 14, 17
    # HH MM SS
    :local dd 0;
    :local HH (($bdt->3) - ($adt->3));
    :local MM (($bdt->4) - ($adt->4));
    :local SS (($bdt->5) - ($adt->5));
    :if ($SS < 0) do={
        :set SS ($SS + 60);
        :set MM ($MM - 1);
    }
    :if ($MM < 0) do={
        :set MM ($MM + 60);
        :set HH ($HH - 1);
    }
    :if ($HH < 0) do={
        :set HH ($HH + 24);
        :set dd ($dd - 1);
    }
    # yyyy mm dd
    :local ayy ($adt->0);
    :local amm ($adt->1);
    :local add ($adt->2);
    :local byy ($bdt->0);
    :local bmm ($bdt->1);
    :local bdd ($bdt->2);
    :local flag true;
    :local fyy;
    :local fmm;
    :local fdd;
    :while ($flag) do={
        :set fyy ($ayy = $byy);
        :set fmm ($amm = $bmm);
        :set fdd ($add = $bdd);
        :if ($fdd) do={
            :if ($fmm) do={
                :if ($fyy) do={
                    :set flag false;
                } else {
                    # same date, skip year
                    :set dd ($dd + 365);
                    :if ([$IsLeapYear $ayy] and ($amm <= 2)) do=[
                        :set dd ($dd + 1);
                    ]
                    :set ayy ($ayy + 1);
                    :if ([$IsLeapYear $ayy] and ($amm > 2)) do=[
                        :set dd ($dd + 1);
                    ]
                }
            } else {
                # same day, skip month
                :set dd ($dd + ($MonthsOfTheYear->($amm - 1)));
                :if (($amm = 2) and [$IsLeapYear $ayy]) do={:set dd ($dd + 1)};
                :set amm ($amm + 1);
                :if ($amm > 12) do={
                    :set amm 1;
                }
            }
        } else {
            # all different
            :if ($bdd > 28) do={
                :set bdd ($bdd - 1);
                :set dd ($dd + 1);
            } else {
                :if ($add < $bdd) do={
                    :set add ($add + 1);
                    :set dd ($dd + 1);
                } else {
                    :set add ($add - 1);
                    :set dd ($dd - 1);
                }
            }
        }
    }
    # make result
    :local result [:totime ("$sign$dd" . "d$HH:$MM:$SS")]
    :return $result;
}


# $GetTimedeltaDiff
# Return a timedelta value that represents the difference of two datetime arrays.
# args: <Datetime>              start point datetime array
# args: <Datetime>              end point datetime array
# return: <Timedelta>           the difference of two datetime arrays
:global GetTimedeltaDiff do={
    # global declare
    :global IsNil;
    :global IsDatetime;
    :global GetTimeDiff;
    :global ToTimedelta;
    # check
    :if (![$IsDatetime $1]) do={:error "Global.Datetime.GetTimedeltaDiff: \$1 should be datetime"};
    :if (![$IsDatetime $2]) do={:error "Global.Datetime.GetTimedeltaDiff: \$2 should be datetime"};
    # local
    :local timeDiff [$GetTimeDiff $1 $2];
    :return [$ToTimedelta $timeDiff];
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
