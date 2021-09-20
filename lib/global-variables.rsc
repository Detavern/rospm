# Global Variables
# =========================================================
# ALL global variables follows upper camel case.
#
# RUN this file first.
# USE as your wish

:local metaInfo {
    "name"="global-variables";
    "version"="0.2.0";
    "description"="global variable package";
    "global"=true;
};

# for framework
:global Nothing;
:global Nil [:find "" "" 1];
:global EmptyArray [:toarray ""];

:global TypeofNothing [:typeof $Nothing];

:global TypeofNil [:typeof $Nil];
:global TypeofStr [:typeof ""];
:global TypeofNum [:typeof 1];
:global TypeofBool [:typeof true];
:global TypeofID [:typeof *0];
:global TypeofTime [:typeof 00:00:00];
:global TypeofIP [:typeof 0.0.0.0];
:global TypeofIPPrefix [:typeof 0.0.0.0/0];
:global TypeofIPv6 [:typeof ::1];
:global TypeofIPv6Prefix [:typeof ::0/0];
:global TypeofArray [:typeof $EmptyArray];

# collect from system
:local sysInfo [/system resource print as-value]
:global SYSArchitectureName ($sysInfo->"architecture-name");
:global SYSBoardName ($sysInfo->"board-name");
:global SYSCPU ($sysInfo->"cpu");
:global SYSCPUCount ($sysInfo->"cpu-count");
:global SYSCPUFrequency ($sysInfo->"cpu-frequency");
:global SYSVersion ($sysInfo->"version");

# script limitation
:global ScriptLengthLimit 30000;
:global VariableLengthLimit 4096;

# datetime
:global MonthsOfTheYear {31;28;31;30;31;30;31;31;30;31;30;31};
:global MonthsName {"jan";"feb";"mar";"apr";"may";"jun";"jul";"aug";"sep";"oct";"nov";"dec"};

# single character to number
:global CharToNum [:toarray ""];
:set ($CharToNum->("\00")) 0;
:set ($CharToNum->("\01")) 1;
:set ($CharToNum->("\02")) 2;
:set ($CharToNum->("\03")) 3;
:set ($CharToNum->("\04")) 4;
:set ($CharToNum->("\05")) 5;
:set ($CharToNum->("\06")) 6;
:set ($CharToNum->("\07")) 7;
:set ($CharToNum->("\08")) 8;
:set ($CharToNum->("\09")) 9;
:set ($CharToNum->("\0A")) 10;
:set ($CharToNum->("\0B")) 11;
:set ($CharToNum->("\0C")) 12;
:set ($CharToNum->("\0D")) 13;
:set ($CharToNum->("\0E")) 14;
:set ($CharToNum->("\0F")) 15;
:set ($CharToNum->("\10")) 16;
:set ($CharToNum->("\11")) 17;
:set ($CharToNum->("\12")) 18;
:set ($CharToNum->("\13")) 19;
:set ($CharToNum->("\14")) 20;
:set ($CharToNum->("\15")) 21;
:set ($CharToNum->("\16")) 22;
:set ($CharToNum->("\17")) 23;
:set ($CharToNum->("\18")) 24;
:set ($CharToNum->("\19")) 25;
:set ($CharToNum->("\1A")) 26;
:set ($CharToNum->("\1B")) 27;
:set ($CharToNum->("\1C")) 28;
:set ($CharToNum->("\1D")) 29;
:set ($CharToNum->("\1E")) 30;
:set ($CharToNum->("\1F")) 31;
:set ($CharToNum->("\20")) 32;
:set ($CharToNum->("\21")) 33;
:set ($CharToNum->("\22")) 34;
:set ($CharToNum->("\23")) 35;
:set ($CharToNum->("\24")) 36;
:set ($CharToNum->("\25")) 37;
:set ($CharToNum->("\26")) 38;
:set ($CharToNum->("\27")) 39;
:set ($CharToNum->("\28")) 40;
:set ($CharToNum->("\29")) 41;
:set ($CharToNum->("\2A")) 42;
:set ($CharToNum->("\2B")) 43;
:set ($CharToNum->("\2C")) 44;
:set ($CharToNum->("\2D")) 45;
:set ($CharToNum->("\2E")) 46;
:set ($CharToNum->("\2F")) 47;
:set ($CharToNum->("\30")) 48;
:set ($CharToNum->("\31")) 49;
:set ($CharToNum->("\32")) 50;
:set ($CharToNum->("\33")) 51;
:set ($CharToNum->("\34")) 52;
:set ($CharToNum->("\35")) 53;
:set ($CharToNum->("\36")) 54;
:set ($CharToNum->("\37")) 55;
:set ($CharToNum->("\38")) 56;
:set ($CharToNum->("\39")) 57;
:set ($CharToNum->("\3A")) 58;
:set ($CharToNum->("\3B")) 59;
:set ($CharToNum->("\3C")) 60;
:set ($CharToNum->("\3D")) 61;
:set ($CharToNum->("\3E")) 62;
:set ($CharToNum->("\3F")) 63;
:set ($CharToNum->("\40")) 64;
:set ($CharToNum->("\41")) 65;
:set ($CharToNum->("\42")) 66;
:set ($CharToNum->("\43")) 67;
:set ($CharToNum->("\44")) 68;
:set ($CharToNum->("\45")) 69;
:set ($CharToNum->("\46")) 70;
:set ($CharToNum->("\47")) 71;
:set ($CharToNum->("\48")) 72;
:set ($CharToNum->("\49")) 73;
:set ($CharToNum->("\4A")) 74;
:set ($CharToNum->("\4B")) 75;
:set ($CharToNum->("\4C")) 76;
:set ($CharToNum->("\4D")) 77;
:set ($CharToNum->("\4E")) 78;
:set ($CharToNum->("\4F")) 79;
:set ($CharToNum->("\50")) 80;
:set ($CharToNum->("\51")) 81;
:set ($CharToNum->("\52")) 82;
:set ($CharToNum->("\53")) 83;
:set ($CharToNum->("\54")) 84;
:set ($CharToNum->("\55")) 85;
:set ($CharToNum->("\56")) 86;
:set ($CharToNum->("\57")) 87;
:set ($CharToNum->("\58")) 88;
:set ($CharToNum->("\59")) 89;
:set ($CharToNum->("\5A")) 90;
:set ($CharToNum->("\5B")) 91;
:set ($CharToNum->("\5C")) 92;
:set ($CharToNum->("\5D")) 93;
:set ($CharToNum->("\5E")) 94;
:set ($CharToNum->("\5F")) 95;
:set ($CharToNum->("\60")) 96;
:set ($CharToNum->("\61")) 97;
:set ($CharToNum->("\62")) 98;
:set ($CharToNum->("\63")) 99;
:set ($CharToNum->("\64")) 100;
:set ($CharToNum->("\65")) 101;
:set ($CharToNum->("\66")) 102;
:set ($CharToNum->("\67")) 103;
:set ($CharToNum->("\68")) 104;
:set ($CharToNum->("\69")) 105;
:set ($CharToNum->("\6A")) 106;
:set ($CharToNum->("\6B")) 107;
:set ($CharToNum->("\6C")) 108;
:set ($CharToNum->("\6D")) 109;
:set ($CharToNum->("\6E")) 110;
:set ($CharToNum->("\6F")) 111;
:set ($CharToNum->("\70")) 112;
:set ($CharToNum->("\71")) 113;
:set ($CharToNum->("\72")) 114;
:set ($CharToNum->("\73")) 115;
:set ($CharToNum->("\74")) 116;
:set ($CharToNum->("\75")) 117;
:set ($CharToNum->("\76")) 118;
:set ($CharToNum->("\77")) 119;
:set ($CharToNum->("\78")) 120;
:set ($CharToNum->("\79")) 121;
:set ($CharToNum->("\7A")) 122;
:set ($CharToNum->("\7B")) 123;
:set ($CharToNum->("\7C")) 124;
:set ($CharToNum->("\7D")) 125;
:set ($CharToNum->("\7E")) 126;
:set ($CharToNum->("\7F")) 127;
:set ($CharToNum->("\80")) 128;
:set ($CharToNum->("\81")) 129;
:set ($CharToNum->("\82")) 130;
:set ($CharToNum->("\83")) 131;
:set ($CharToNum->("\84")) 132;
:set ($CharToNum->("\85")) 133;
:set ($CharToNum->("\86")) 134;
:set ($CharToNum->("\87")) 135;
:set ($CharToNum->("\88")) 136;
:set ($CharToNum->("\89")) 137;
:set ($CharToNum->("\8A")) 138;
:set ($CharToNum->("\8B")) 139;
:set ($CharToNum->("\8C")) 140;
:set ($CharToNum->("\8D")) 141;
:set ($CharToNum->("\8E")) 142;
:set ($CharToNum->("\8F")) 143;
:set ($CharToNum->("\90")) 144;
:set ($CharToNum->("\91")) 145;
:set ($CharToNum->("\92")) 146;
:set ($CharToNum->("\93")) 147;
:set ($CharToNum->("\94")) 148;
:set ($CharToNum->("\95")) 149;
:set ($CharToNum->("\96")) 150;
:set ($CharToNum->("\97")) 151;
:set ($CharToNum->("\98")) 152;
:set ($CharToNum->("\99")) 153;
:set ($CharToNum->("\9A")) 154;
:set ($CharToNum->("\9B")) 155;
:set ($CharToNum->("\9C")) 156;
:set ($CharToNum->("\9D")) 157;
:set ($CharToNum->("\9E")) 158;
:set ($CharToNum->("\9F")) 159;
:set ($CharToNum->("\A0")) 160;
:set ($CharToNum->("\A1")) 161;
:set ($CharToNum->("\A2")) 162;
:set ($CharToNum->("\A3")) 163;
:set ($CharToNum->("\A4")) 164;
:set ($CharToNum->("\A5")) 165;
:set ($CharToNum->("\A6")) 166;
:set ($CharToNum->("\A7")) 167;
:set ($CharToNum->("\A8")) 168;
:set ($CharToNum->("\A9")) 169;
:set ($CharToNum->("\AA")) 170;
:set ($CharToNum->("\AB")) 171;
:set ($CharToNum->("\AC")) 172;
:set ($CharToNum->("\AD")) 173;
:set ($CharToNum->("\AE")) 174;
:set ($CharToNum->("\AF")) 175;
:set ($CharToNum->("\B0")) 176;
:set ($CharToNum->("\B1")) 177;
:set ($CharToNum->("\B2")) 178;
:set ($CharToNum->("\B3")) 179;
:set ($CharToNum->("\B4")) 180;
:set ($CharToNum->("\B5")) 181;
:set ($CharToNum->("\B6")) 182;
:set ($CharToNum->("\B7")) 183;
:set ($CharToNum->("\B8")) 184;
:set ($CharToNum->("\B9")) 185;
:set ($CharToNum->("\BA")) 186;
:set ($CharToNum->("\BB")) 187;
:set ($CharToNum->("\BC")) 188;
:set ($CharToNum->("\BD")) 189;
:set ($CharToNum->("\BE")) 190;
:set ($CharToNum->("\BF")) 191;
:set ($CharToNum->("\C0")) 192;
:set ($CharToNum->("\C1")) 193;
:set ($CharToNum->("\C2")) 194;
:set ($CharToNum->("\C3")) 195;
:set ($CharToNum->("\C4")) 196;
:set ($CharToNum->("\C5")) 197;
:set ($CharToNum->("\C6")) 198;
:set ($CharToNum->("\C7")) 199;
:set ($CharToNum->("\C8")) 200;
:set ($CharToNum->("\C9")) 201;
:set ($CharToNum->("\CA")) 202;
:set ($CharToNum->("\CB")) 203;
:set ($CharToNum->("\CC")) 204;
:set ($CharToNum->("\CD")) 205;
:set ($CharToNum->("\CE")) 206;
:set ($CharToNum->("\CF")) 207;
:set ($CharToNum->("\D0")) 208;
:set ($CharToNum->("\D1")) 209;
:set ($CharToNum->("\D2")) 210;
:set ($CharToNum->("\D3")) 211;
:set ($CharToNum->("\D4")) 212;
:set ($CharToNum->("\D5")) 213;
:set ($CharToNum->("\D6")) 214;
:set ($CharToNum->("\D7")) 215;
:set ($CharToNum->("\D8")) 216;
:set ($CharToNum->("\D9")) 217;
:set ($CharToNum->("\DA")) 218;
:set ($CharToNum->("\DB")) 219;
:set ($CharToNum->("\DC")) 220;
:set ($CharToNum->("\DD")) 221;
:set ($CharToNum->("\DE")) 222;
:set ($CharToNum->("\DF")) 223;
:set ($CharToNum->("\E0")) 224;
:set ($CharToNum->("\E1")) 225;
:set ($CharToNum->("\E2")) 226;
:set ($CharToNum->("\E3")) 227;
:set ($CharToNum->("\E4")) 228;
:set ($CharToNum->("\E5")) 229;
:set ($CharToNum->("\E6")) 230;
:set ($CharToNum->("\E7")) 231;
:set ($CharToNum->("\E8")) 232;
:set ($CharToNum->("\E9")) 233;
:set ($CharToNum->("\EA")) 234;
:set ($CharToNum->("\EB")) 235;
:set ($CharToNum->("\EC")) 236;
:set ($CharToNum->("\ED")) 237;
:set ($CharToNum->("\EE")) 238;
:set ($CharToNum->("\EF")) 239;
:set ($CharToNum->("\F0")) 240;
:set ($CharToNum->("\F1")) 241;
:set ($CharToNum->("\F2")) 242;
:set ($CharToNum->("\F3")) 243;
:set ($CharToNum->("\F4")) 244;
:set ($CharToNum->("\F5")) 245;
:set ($CharToNum->("\F6")) 246;
:set ($CharToNum->("\F7")) 247;
:set ($CharToNum->("\F8")) 248;
:set ($CharToNum->("\F9")) 249;
:set ($CharToNum->("\FA")) 250;
:set ($CharToNum->("\FB")) 251;
:set ($CharToNum->("\FC")) 252;
:set ($CharToNum->("\FD")) 253;
:set ($CharToNum->("\FE")) 254;
:set ($CharToNum->("\FF")) 255;

# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
