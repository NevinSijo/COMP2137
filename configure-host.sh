


trap '' TERM HUP INT

VERBOSE=0

log() {
    if [ $VERBOSE -eq 1 ]; then
        echo "$1"
    fi
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -verbose)
        VERBOSE=1
        shift
        ;;
        -name)
        NAME="$2"
        shift
        shift
        ;;
        -ip)
        IP="$2"
        shift
        shift
        ;;
        -hostentry)
        HOSTNAME="$2"
        HOSTIP="$3"
        shift
        shift
        shift
        ;;
        *)
        echo "Unknown option $1"
        exit 1
        ;;
    esac
done


if [ ! -z "$NAME" ]; then
    CURRENT_NAME=$(hostname)
    if [ "$CURRENT_NAME" != "$NAME" ]; then
        log "Changing hostname from $CURRENT_NAME to $NAME"
        echo "$NAME" > /etc/hostname
        hostnamectl set-hostname "$NAME"
        sed -i "s/$CURRENT_NAME/$NAME/g" /etc/hosts
        logger "Hostname changed from $CURRENT_NAME to $NAME"
    else
        log "Hostname is already $NAME"
    fi
fi


if [ ! -z "$IP" ]; then
    CURRENT_IP=$(hostname -I | awk '{print $1}')
    if [ "$CURRENT_IP" != "$IP" ]; then
        log "Changing IP address from $CURRENT_IP to $IP"
        NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"
        sed -i "s/$CURRENT_IP/$IP/g" $NETPLAN_FILE
        netplan apply
        sed -i "/$CURRENT_NAME/d" /etc/hosts
        echo "$IP $CURRENT_NAME" >> /etc/hosts
        logger "IP address changed from $CURRENT_IP to $IP"
    else
        log "IP address is already $IP"
    fi
fi


if [ ! -z "$HOSTNAME" ] && [ ! -z "$HOSTIP" ]; then
    if ! grep -q "$HOSTNAME" /etc/hosts; then
        log "Adding $HOSTNAME with IP $HOSTIP to /etc/hosts"
        echo "$HOSTIP $HOSTNAME" >> /etc/hosts
        logger "Added $HOSTNAME with IP $HOSTIP to /etc/hosts"
    else
        log "$HOSTNAME already in /etc/hosts"
    fi
fi
