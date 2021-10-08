# Global Functions | Cache
# =========================================================
# ALL global functions follows upper camel case.
# Global Cache get, put, update, dalete
#
# USE as your wish

:local metaInfo {
    "name"="global-functions.cache";
    "version"="0.3.0";
    "description"="global functions for cache operation";
    "global"=true;
    "global-functions"={
        "GlobalCacheFuncGet";
        "GlobalCacheFuncPut";
        "GlobalCacheFuncRemove";
        "GlobalCacheFuncRemovePrefix";
        "GlobalCacheFuncFlush";
        "GlobalCacheFuncStatus";
    };
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
    :global GlobalCacheFuncStatus;
    # local
    :local funcCache;
    # check existance
    :if (![$IsNothing $GlobalCacheFunc]) do={
        :set funcCache (($GlobalCacheFunc->"data")->$1);
        :if (![$IsNothing $funcCache]) do={
            # if wanted a head node, return it
            :if (($GlobalCacheFunc->"head") = $1) do={
                :return ($funcCache->"var");
            }
            # if wanted a tail node, change its previous one as new tail
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
            :set ((($GlobalCacheFunc->"data")->($GlobalCacheFunc->"head"))->"prev") $1;
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
:global GlobalCacheFuncPut do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global NewArray;
    :global GlobalCacheFunc;
    :global GlobalCacheFuncGet;
    # env
    :global EnvGlobalCacheFuncSize;
    :global EnvGlobalCacheFuncEnabled;
    # should not happened
    :if ([$IsNothing $EnvGlobalCacheFuncSize]) do={:error "cache size is nothing"}
    # local
    :local funcCache;
    :local cacheSize $EnvGlobalCacheFuncSize;
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
        # if cache out of size, remove the tail one
        :if ([:len ($GlobalCacheFunc->"data")] >= $cacheSize) do={
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


# $GlobalCacheFuncStatus
# print status
:global GlobalCacheFuncStatus do={
    # global declare
    :global Nil;
    :global IsNil;
    :global IsNothing;
    :global GlobalCacheFunc;
    # check
    :if ([$IsNothing $GlobalCacheFunc]) do={
        :put "Global.cache.GlobalCacheFuncStatus: not initialized."
        :return $Nil;
    }
    :put "==================== GlobalCacheFuncStatus ====================";
    :local length [:len ($GlobalCacheFunc->"data")];
    :local head ($GlobalCacheFunc->"head");
    :local tail ($GlobalCacheFunc->"tail");
    :put "Linkedlist Size: $length";
    :put "Linkedlist Head: $head";
    :put "Linkedlist Tail: $tail";
    :local prev;
    :local next;
    :local code;
    :put "------------------ Linkedtable Content Trace ------------------";
    :put "Linkedlist Content Trace:";
    :local max 30;
    :local cursor $head;
    :local cc 0;
    :local flag true;
    :local node;
    :while ($flag and ($cc < $max)) do={
        :set node (($GlobalCacheFunc->"data")->$cursor);
        :set code [:len (($node->"var")->1)];
        :set prev ($node->"prev");
        :set next ($node->"next");
        :put "    $cursor";
        :put "        code: $code";
        :put "        prev: $prev";
        :put "        next: $next";
        :if ([$IsNil $next]) do={
            :set flag false;
        } else {
            :set cursor $next;
        }
        :set cc ($cc + 1);
    }
}


# package info
:local package {
    "metaInfo"=$metaInfo;
}
:return $package;
