#!/bin/sh

# Telegram notification script
TELEGRAM_SCRIPT="/C/Users/YoungWolf/Documents/send_telegram.sh"

# List of ASIC miners
ASIC_IPS=("192.168.1.49" "192.168.1.146")
HOSTNAMES=("Antminer-L3+ #1" "Antminer-L3+ #2")

for i in 0 1; do
    ASIC_IP="${ASIC_IPS[$i]}"
    HOSTNAME="${HOSTNAMES[$i]}"

    echo "Checking $HOSTNAME at $ASIC_IP..."

    # Try to talk to cgminer API
    if ! echo 'version' | nc -w 2 "$ASIC_IP" 4028 2>/dev/null | grep -q "cgminer"; then
        echo "❌ $HOSTNAME is not responding, restarting cgminer..."
        ssh REDACTED@"$ASIC_IP" "/etc/init.d/cgminer.sh restart"
        sh "$TELEGRAM_SCRIPT"
    else
        echo "✅ $HOSTNAME is alive and running cgminer."
    fi
done

