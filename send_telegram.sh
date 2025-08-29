    #!/bin/sh

    TOKEN="REDACTED"
    CHAT_ID="REDACTED"
    MESSAGE="Watchdog restarted cgminer on $(hostname) at $(date)"

    DATA="chat_id=${CHAT_ID}&text=$(echo "$MESSAGE" | sed 's/ /%20/g')"

    printf "POST /bot%s/sendMessage HTTP/1.1\r\nHost: api.telegram.org\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: %d\r\n\r\n%s" \
    "$TOKEN" "$(echo -n "$DATA" | wc -c)" "$DATA" | openssl s_client -connect api.telegram.org:443 -quiet
