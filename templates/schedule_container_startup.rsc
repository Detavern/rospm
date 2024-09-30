# wait for ROSPM initialized
:delay 10s;

# global declare
:global IsNil;
:global IsEmpty;
:global GetConfig;

# local
:local cFlag true;
:local mounted false;
:local cur 0;
:local maxWaitSec 15;
:local config ([$GetConfig "config.deployment"]->"deployment");
:local mountDir ((($config->"container")->"config")->"storage");
:local ctnDir "$mountDir/containers";

# usb power reset
/system/routerboard/usb/power-reset duration=5s;
:delay 5s;

:while (!$mounted && ($maxWaitSec > $cur)) do={
    :if ([$IsEmpty [/file/find name=$ctnDir]]) do={
        /log/info "ROSPM Container startup: $ctnDir is not mounted yet";
        :set cur ($cur + 1);
        :delay 2s
    } else={
        /log/info "ROSPM Container startup: $ctnDir is mounted";
        :set mounted true;
        :delay 2s;
    }
}

:if (!$mounted) do={
    :set cFlag false;
    /log/error "ROSPM Container startup: could not find container directory $ctnDir";
}

:if ($cFlag) do={
    # TODO: add a manual delay for each container
    :foreach itemID in [/container/find] do={
        /container/start $itemID
    }
    /log/info "ROSPM Container startup: All containers started";
}
