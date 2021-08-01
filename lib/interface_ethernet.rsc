:local metaInfo {
    "name"="interface.ethernet";
    "version"="0.0.1";
    "description"="";
};


# :put [$renameEthernet src-default-name=<default-name|str> name=<new name>]
# $renameEthernet
# kwargs: srcID=[<id>]
# kwargs: srcDefaultName=[<str>]
# kwargs: srcName=[<str>]
# kwargs: iName=<str>
:local renameEthernet do={
    #DEFINE global
    :global TypeofStr;
    :global IsEmpty;
    :global IsStr;
    :global EmptyArray;
    # check name
    :if (![$IsStr $iName]) do={
        :error "renameEthernet: require \$iName";
    }
    # find ID by srcDefaultName & replace its name
    :if ([$IsStr $srcDefaultName]) do={
        :local nicIDList [/interface ethernet find default-name=$srcDefaultName];
        :if ([$IsEmpty $nicIDList]) do={
            :error "renameEthernet: srcDefaultName not found";
        } else {
            :local nicID ($nicIDList->0);
            /interface ethernet set name=$iName numbers=$nicID;
        }
        :return true;
    }
    # find ID by srcName & replace its name
    :if ([$IsStr $srcName]) do={
        :local nicIDList [/interface ethernet find name=$srcName];
        :if ([$IsEmpty $nicIDList]) do={
            :error "renameEthernet: srcName not found";
        } else {
            :local nicID ($nicIDList->0);
            /interface ethernet set name=$iName numbers=$nicID;
        }
        :return true;
    }
    :error "renameEthernet: require one of \$srcID, \$srcDefaultName, \$srcName";
}


# :put [$renameAllByTemplate template={<default-name|str>=<name|str>;}]
# $renameAllByTemplate
# kwargs: template={<default-name|str>=<name|str>;}
:local renameAllByTemplate do={
    #DEFINE global
    :global TypeofStr;
    :global IsArray;
    :global Replace;
    :global StartsWith;
    # check template
    :if (![$IsArray $template]) do={
        :error "renameAllByTemplate: require \$template";
    }
    # for
    :foreach i in=[/interface ethernet find] do={
        :local iName [/interface ethernet get $i "default-name"];
        :local iNameP "";
        # select longest match pattern
        :foreach k,v in=$template do={
            :if ([$StartsWith $iName $k]) do={
                :if ([:len $k]>[:len $iNameP]) do={
                    :set iNameP $k;
                }
            }
        }
        # replace it
        :if ($iNameP!="") do={
            :local name [$Replace $iName $iNameP ($template->$iNameP)];
            /interface ethernet set name=$name numbers=$i;
        }
    }
}


# :put [$renameAllByTemplate template={<default-name|str>=<name|str>;}]
# $renameAllByTemplate
# kwargs: template={<default-name|str>=<name|str>;}
:local resetDefaultName do={
    :foreach i in=[/interface ethernet find] do={
        :local defaultName [/interface ethernet get $i "default-name"];
        /interface ethernet set name=$defaultName numbers=$i;
    }
}


:local package {
    "metaInfo"=$metaInfo;
    "renameEthernet"=$renameEthernet;
    "renameAllByTemplate"=$renameAllByTemplate;
    "resetDefaultName"=$resetDefaultName;
}
:return $package;
