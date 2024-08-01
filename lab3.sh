

VERBOSE=0

if [[ "$1" == "-verbose" ]]; then
    VERBOSE=1
fi

if [ $VERBOSE -eq 1 ]; then
    SCP="scp -v"
    SSH="ssh -v"
else
    SCP="scp"
    SSH="ssh"
fi

$SCP configure-host.sh remoteadmin@server1-mgmt:/root
$SSH remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 -verbose $VERBOSE

$SCP configure-host.sh remoteadmin@server2-mgmt:/root
$SSH remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 -verbose $VERBOSE

./configure-host.sh -hostentry loghost 192.168.16.3 -verbose $VERBOSE
./configure-host.sh -hostentry webhost 192.168.16.4 -verbose $VERBOSE
