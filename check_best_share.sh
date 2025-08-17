#!/bin/sh
echo "Ran at $(date)" >> /tmp/best_share_log.txt

USER="root"
PASS="Mikkopaska03"

ASIC_IPS=("192.168.1.49" "192.168.1.146")
HOSTNAMES=("Antminer-L3+ #1" "Antminer-L3+ #2")
LAST_FILES=("C:/Users/YoungWolf/Documents/last_best_share_1.txt" "C:/Users/YoungWolf/Documents/last_best_share_2.txt")

TOKEN="7262132730:AAE3lmwtkvAoKhua4VC1sYlut0hPSW_HIrQ"
CHAT_ID="1937969055"

# CREATE missing last best share files if they don't exist
for i in 0 1; do
  LAST_FILE="${LAST_FILES[$i]}"
  if [ ! -f "$LAST_FILE" ]; then
    echo 0 > "$LAST_FILE"
  fi
done

# MAIN LOOP
for i in 0 1; do
  ASIC_IP="${ASIC_IPS[$i]}"
  HOSTNAME="${HOSTNAMES[$i]}"
  LAST_FILE="${LAST_FILES[$i]}"

  response=$(curl -s --digest -u "$USER:$PASS" "http://$ASIC_IP/cgi-bin/get_miner_status.cgi")

  best_share=$(echo "$response" | jq -r '.summary.bestshare')
  [ -z "$best_share" ] && echo "Failed to get best_share from $HOSTNAME" && continue

  if [ -f "$LAST_FILE" ]; then
    last=$(cat "$LAST_FILE")
  else
    last=0
  fi

  if [ "$best_share" != "$last" ]; then
    echo "New best share on $HOSTNAME: $best_share"
    echo "$best_share" > "$LAST_FILE"

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    MESSAGE="⚠️🧠 *ASIC Alertn*

\`\`\`
🧮  Best Share :  $best_share
📦  Previous   :  $last
🖥️  Host      :  $HOSTNAME
⏰  Time      :  $TIMESTAMP
\`\`\`"

    DATA="chat_id=$CHAT_ID&text=$(echo "$MESSAGE" | sed 's/ /%20/g; s/`/%60/g; s/"/%22/g; s/\n/%0A/g')&parse_mode=MarkdownV2"

    printf "POST /bot$TOKEN/sendMessage HTTP/1.1\r\nHost: api.telegram.org\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: %d\r\n\r\n%s" \
    "$(echo -n "$DATA" | wc -c)" "$DATA" | openssl s_client -connect api.telegram.org:443 -quiet
  else
    echo "No new best share on $HOSTNAME. Current: $best_share"
  fi
done
