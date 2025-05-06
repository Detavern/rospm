#!rsc by RouterOS
# ===================================================================
# |     Global Functions     |   global-functions.unicode
# ===================================================================
# ALL global functions follows upper camel case.
# Global Package for unicode related operation
#
# Copyright (c) 2020-2023 detavern <detavern@live.com>
# https://github.com/Detavern/rospm/blob/master/LICENSE.md
#
:local metaInfo {
	"name"="global-functions.unicode";
	"version"="0.6.0";
	"description"="Global Package for unicode related operation";
	"global"=true;
	"global-functions"={
		"ByteToChar";
		"CharToByte";
		"UnicodeToUtf8";
		"Utf8ToUnicode";
		"Utf8ToUnicodeEscaped";
		"EncodeUtf8";
		"DecodeUtf8";
	};
};


# $ByteToChar
# convert a single byte to character
# args: <num>                   num, 0x00 to 0xFF
# return: <str>                 character
:global ByteToChar do={
	:if ($1 > 255) do={
		:error "Global.ByteToChar: \$1 should smaller than 256";
	}
	:local h1 [:pick "0123456789ABCDEF" (($1 >> 4) & 0xF)];
	:local h2 [:pick "0123456789ABCDEF" ($1 & 0xF)];
	:return [[:parse "(\"\\$h1$h2\")"]];
}


# $CharToByte
# convert a single byte length character into byte(num)
# args: <str>                   character
# return: <num>                 num, 0x00 to 0xFF
:global CharToByte do={
	# global
	:global CharToNum;
	:global IsNothing;
	# local
	:local n ($CharToNum->$1);
	:if ([$IsNothing $n]) do={
		:error "Global.CharToByte: \$1 should smaller than 256";
	}
	:return $n;
}


# $UnicodeToUtf8
# convert single unicode code point into utf-8 character
# unicode: U+0000 - U+10FFFF
# start     end         byte count      byte 1
# U+0000    U+007F      1 char          0xxx xxxx
# U+0080    U+07FF      2 char          110x xxxx
# U+0800    U+FFFF      3 char          1110 xxxx
# U+10000   U+10FFFF    4 char          1111 0xxx
# args: <num>                   num, U+0000 to U+10FFFF
# return: <str>                 character
:global UnicodeToUtf8 do={
	# global
	:global TypeRecovery;
	:global ByteToChar;
	# check
	:local unicode [$TypeRecovery $1];
	:if (($1 > 0x10FFFF) or ($1 < 0)) do={
		:error "Global.Encode: not in range(0x0000 to 0x110000)";
	}
	:local byteNum;
	:local result "";
	# local
	:if ($1 < 0x80) do={
		:return [$ByteToChar $1];
	} else {
		:if ($1 < 0x800) do={
			:set byteNum 2;
		} else {
			:if ($1 < 0x10000) do={
				:set byteNum 3;
			} else {
				:set byteNum 4;
			}
		}
	}
	:for i from=2 to=$byteNum step=1 do={
		# pick last 6 bit and prepend 10 ahead, that make a byte 10xx xxxx(continuation byte)
		:set result ([$ByteToChar ($unicode & 0x3F | 0x80)] . $result)
		:set unicode ($unicode >> 6)
	}
	# make first byte
	:set result ([$ByteToChar (((0xFF00 >> $byteNum) & 0xFF) | $unicode)] . $result);
	:return $result;
}


# $Utf8ToUnicode
# convert an utf-8 character into unicode code point
# args: <str>                   utf8 encoded character
# return: <num>                 unicode code point
:global Utf8ToUnicode do={
	# global
	:global CharToByte;
	# check
	:local strLen [:len $1];
	:local fb [$CharToByte [:pick $1 0]];
	:local ch;
	:local unicode 0;
	# ascii
	:if ($strLen = 1) do={
		:return [$CharToByte $1];
	}
	# handle first byte
	:if ($strLen = 2) do={
		:set unicode ($fb & 0x1F);
	} else {
		:set unicode ($fb & 0xF);
	}
	# handle continuation byte
	:for i from=2 to=$strLen step=1 do={
		:set unicode ($unicode << 6);
		:set ch [$CharToByte [:pick $1 ($i - 1)]];
		# check start 10xx xxxx
		:if (($ch >> 6) != 2) do={
			:error "Global.Utf8ToUnicode: continuation byte should startswith 0b10";
		}
		# pick last 6 bit
		:set unicode ($ch & 0x3F | $unicode);
	}
	:return $unicode;
}


# $Utf8ToUnicodeEscaped
# convert an utf-8 character into escaped unicode string
# args: <str>                   utf8 encoded string
# return: <str>                 escaped unicode string
:global Utf8ToUnicodeEscaped do={
	# global
	:global Utf8ToUnicode;
	:global ByteToChar;
	:global NumToHex;
	# local
	:local result "\\u";
	:local unicode [$Utf8ToUnicode $1];
	# printable ascii
	:if (($unicode <= 0x7E) and ($unicode >= 0x20)) do={
		:return [$ByteToChar $unicode];
	}
	:if ($unicode <= 0xFFFF) do={
		:local hex [$NumToHex $unicode];
		:local hexT [:pick $hex 2 [:len $hex]];
		:local hexLen [:len $hexT];
		:for i from=$hexLen to 3 step=1 do={
			:set result ($result . "0");
		}
		:set result ($result . "$hexT");
	} else {
		:local ch ($unicode & 0xFFFF);
		:local high (($ch >> 10) + 0xD800);
		:local low (($ch & 0x3FF) + 0xDC00);
		:local hexH [$NumToHex $high];
		:local hexL [$NumToHex $low];
		:set result ($result . [:pick $hexH 2 [:len $hexH]] . "\\u" . [:pick $hexL 2 [:len $hexL]]);
	}
	:return $result;
}


# $EncodeUtf8
# encode a string which contains escaped unicode string into Utf8
# args: <str>                   string contains escaped unicode
# return: <str>                 encoded
:global EncodeUtf8 do={
	#DEFINE global
	:global UnicodeToUtf8;
	# local
	:local string $1;
	:local cursor 0;
	:local ch;
	:local nch;
	:local result "";
	:while ($cursor < [:len $string]) do={
		:set ch [:pick $string $cursor];
		:if ($ch = "\\") do={
			# char escape
			:local ch2 [:pick $string ($cursor + 1)];
			:if ($ch2 = "u") do={
				# unicode escape
				:local unicodeStr [:pick $string ($cursor + 2) ($cursor + 6)];
				:local unicode [:tonum "0x$unicodeStr"];
				:if ($unicode >= 0xD800 and $utf <= 0xDFFF) do={
					# unicode pair surrogate
					# \uxxxx\uxxxx 12 chars
					:local surrogateHigh (($unicode & 0x3FF) << 10);
					:local surrogateLowStr [:pick $string ($cursor + 8) ($cursor + 12)];
					:local surrogateLow ([:tonum "0x$surrogateLowStr"] & 0x3FF);
					:set unicode ($surrogateHigh | $surrogateLow | 0x10000);
					:set $cursor ($cursor + 12);
				} else {
					# basic multilingual plane
					# \uxxxx 6 chars
					:set $cursor ($cursor + 6);
				}
				# convert code point to utf-8 str
				:set nch [$UnicodeToUtf8 $unicode];
			} else {
				# other escape
				:if ($ch2 ~ "[\\bfnrt\"]") do={
					:set nch [[:parse "(\"\\$ch2\")"]];
					:set $cursor ($cursor + 2);
				} else {
					:if ($ch2 = "/") do={
						:set $cursor ($cursor + 2);
						:set nch $ch2;
					} else {
						:local pos $cursor;
						:error "Global.EncodeUtf8: pos: $pos, expected token after \\";
					}
				}
			}
		} else {
			:set nch $ch;
			:set $cursor ($cursor + 1);
		}
		:set result ($result . $nch)
	}
	# skip whitespace
	:return $result;
}


# $DecodeUtf8
# decode a utf8 encoded string into escaped unicode string.
# args: <str>                   utf8 encoded string
# return: <str>                 string with escaped unicode
:global DecodeUtf8 do={
	#DEFINE global
	:global Utf8ToUnicodeEscaped;
	:global CharToNum;
	# local
	:local string $1;
	:local cursor 0;
	:local ch;
	:local chs;
	:local charNum;
	:local nch;
	:local result "";
	:while ($cursor < [:len $string]) do={
		:set ch [:pick $string $cursor];
		:set charNum ($CharToNum->$ch);
		:local high ($charNum >> 3);
		# 1111 0xxx
		:if ($high = 0x1E) do={
			:set ch [:pick $string $cursor ($cursor + 4)];
			:set $cursor ($cursor + 3);
		} else {
			# 1110 xxxx
			:set high ($high >> 1);
			:if ($high = 0xE) do={
				:set ch [:pick $string $cursor ($cursor + 3)];
				:set $cursor ($cursor + 2);
			} else {
				# 110x xxxx
				:set high ($high >> 1);
				:if ($high = 0x6) do={
					:set ch [:pick $string $cursor ($cursor + 2)];
					:set $cursor ($cursor + 1);
				} else {
					# 0xxx xxxx
					:if (($high >> 2) != 0) do={
						:error "Global.DecodeUtf8: utf8 decode error";
					}
				}
			}
		}
		:set nch [$Utf8ToUnicodeEscaped $ch];
		:set result ($result . $nch);
		:set $cursor ($cursor + 1);
	}
	:return $result;
}

# package info
:local package {
	"metaInfo"=$metaInfo;
}
:return $package;
