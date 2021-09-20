# Global Functions | Cache
# =========================================================
# ALL global functions follows upper camel case.
# Global Cache get, put, update, dalete
#
# USE as your wish

:local metaInfo {
    "name"="global-functions.cache";
    "version"="0.2.0";
    "description"="global functions for cache operation";
    "global"=true;
};


# $GlobalCacheFuncGet
# get var from cache
# args: <name>                      name of var
:global GlobalCacheFuncGet do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global GlobalCacheFunc;
    # local
    :local funcCache;
    # check existance
    :if (![$IsNothing $GlobalCacheFunc]) do={
        :set funcCache (($GlobalCacheFunc->"data")->$1);
        :if (![$IsNothing $funcCache]) do={
            # head
            :if (($GlobalCacheFunc->"head") = $1) do={
                :return ($funcCache->"var");
            }
            # tail
            :if (($GlobalCacheFunc->"tail") = $1) do={
                :set ($GlobalCacheFunc->"tail") ($funcCache->"prev");
            }
            # resort cache
            :if (![$IsNil ($funcCache->"prev")]) do={
                :set ((($GlobalCacheFunc->"data")->($funcCache->"prev"))->"next") ($funcCache->"next")
            }
            :if (![$IsNil ($funcCache->"next")]) do={
                :set ((($GlobalCacheFunc->"data")->($funcCache->"next"))->"prev") ($funcCache->"prev")
            }
            :set ($funcCache->"prev") $Nil;
            :set ($funcCache->"next") ($GlobalCacheFunc->"head");
            :set ($GlobalCacheFunc->"head") $1;
            # return
            :return ($funcCache->"var");
        }
    }
    :return $Nil;
}


# $GlobalCacheFuncPut
# put(update) var into cache
# args: <name>                      name of var
# args: <var>                       value of var
# args: <size>                      size of cache
:global GlobalCacheFuncPut do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global NewArray;
    :global GlobalCacheFunc;
    :global GlobalCacheFuncGet;
    # local
    :local funcCache;
    :local cacheSize $3;
    # check cache
    :if ([$IsNothing $GlobalCacheFunc]) do={
        :set GlobalCacheFunc [$NewArray ];
        :set ($GlobalCacheFunc->"data") [$NewArray ];
        :set ($GlobalCacheFunc->"head") $Nil;
        :set ($GlobalCacheFunc->"tail") $Nil;
    }
    :local func [$GlobalCacheFuncGet $1];
    :if ([$IsNil $func]) do={
        # put
        # set func cache
        :set funcCache [$NewArray ];
        :set ($funcCache->"name") $1;
        :set ($funcCache->"var") $2;
        :set ($funcCache->"prev") $Nil;
        :set ($funcCache->"next") $Nil;
        # set head & tail
        :local head ($GlobalCacheFunc->"head");
        :local tail ($GlobalCacheFunc->"tail");
        # if cache no empty, remove the tail one
        :if ([:len $GlobalCacheFunc] >= $cacheSize) do={
            :local tailPrev ((($GlobalCacheFunc->"data")->$tail)->"prev");
            :set ((($GlobalCacheFunc->"data")->$tailPrev)->"next") $Nil;
            # set new tail
            :set ($GlobalCacheFunc->"tail") $tailPrev;
            :set (($GlobalCacheFunc->"data")->$tail);
            :set tail $tailPrev;
        }
        # current head as node's next
        :if (![$IsNil $head]) do={
            :set ($funcCache->"next") $head;
            :set ((($GlobalCacheFunc->"data")->$head)->"prev") $1;
        }
        # set new head
        :set ($GlobalCacheFunc->"head") $1;
        :set (($GlobalCacheFunc->"data")->$1) $funcCache;
        # tail
        :if ([$IsNil ($GlobalCacheFunc->"tail")]) do={
            :set ($GlobalCacheFunc->"tail") $1;
        }
    } else {
        # update
        :set funcCache (($GlobalCacheFunc->"data")->$1);
        :set ($funcCache->"var") $2;
    }
}


# $GlobalCacheFuncRemove
# remove var from cache
# args: <name>                      prefix
:global GlobalCacheFuncRemove do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global GlobalCacheFunc;
    # local
    :local funcCache (($GlobalCacheFunc->"data")->$1);
    :if (![$IsNothing $funcCache]) do={
        # head
        :if (($GlobalCacheFunc->"head") = $1) do={
            :set ($GlobalCacheFunc->"head") ($funcCache->"next");
        }
        # tail
        :if (($GlobalCacheFunc->"tail") = $1) do={
            :set ($GlobalCacheFunc->"tail") ($funcCache->"prev");
        }
        # resort cache
        :if (![$IsNil ($funcCache->"prev")]) do={
            :set ((($GlobalCacheFunc->"data")->($funcCache->"prev"))->"next") ($funcCache->"next")
        }
        :if (![$IsNil ($funcCache->"next")]) do={
            :set ((($GlobalCacheFunc->"data")->($funcCache->"next"))->"prev") ($funcCache->"prev")
        }
        # remove
        :set (($GlobalCacheFunc->"data")->$1);
    }
}


# $GlobalCacheFuncRemovePrefix
# remove var from cache by prefix
# args: <name>                      name of var
:global GlobalCacheFuncRemovePrefix do={
    # global declare
    :global NewArray;
    :global StartsWith;
    :global GlobalCacheFunc;
    :global GlobalCacheFuncRemove;
    # local
    :local nameList [$NewArray ];
    :foreach k,v in ($GlobalCacheFunc->"data") do={
        :if ([$StartsWith $k $1]) do={
            :set ($nameList->[:len $nameList]) $k;
        }
    }
    :foreach v in $nameList do={
        [$GlobalCacheFuncRemove $v];
    }
}


# $GlobalCacheFuncFlush
# flush all cache
:global GlobalCacheFuncFlush do={
    # global declare
    :global Nil;
    :global NewArray;
    :global GlobalCacheFunc;
    # flush
    :set GlobalCacheFunc [$NewArray ];
    :set ($GlobalCacheFunc->"data") [$NewArray ];
    :set ($GlobalCacheFunc->"head") $Nil;
    :set ($GlobalCacheFunc->"tail") $Nil;
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
