#!/bin/bash

# ================= CONFIGURATION =================
WEBHOOK_URL=$(aws ssm get-parameter --name "WEBHOOK_URL" --with-decryption --query "Parameter.Value" --output text)
WAZUH_USER=$(aws ssm get-parameter --name "WAZUH_USER" --with-decryption --query "Parameter.Value" --output text)
WAZUH_PASS=$(aws ssm get-parameter --name "WAZUH_PASS" --with-decryption --query "Parameter.Value" --output text)
INDEXER_URL="https://indexer:9200"
INDEXER_USER=$(aws ssm get-parameter --name "INDEXER_USER" --with-decryption --query "Parameter.Value" --output text)
INDEXER_PASS=$(aws ssm get-parameter --name "INDEXER_PASS" --with-decryption --query "Parameter.Value" --output text)
SYSLOG_HOST=$(aws ssm get-parameter --name "SYSLOG_HOST" --with-decryption --query "Parameter.Value" --output text)
SYSLOG_PORT=514
NODEPORT_WAZUH=32467  # NodePort exposed for the Wazuh service

# ================= SET ABSOLUTE PATH =================
export PATH=/usr/local/bin:/usr/bin:/bin

# ================= FUNCTIONS =================
send_to_chat() {
    local msg="$1"
    /usr/bin/curl -s -X POST "$WEBHOOK_URL" \
         -H "Content-Type: application/json; charset=UTF-8" \
         -d "{\"text\": \"$msg\"}" >/dev/null 2>&1 || echo "⚠️ Error sending message to Google Chat"
}

# ================= 1. Get IP of a cluster node =================
NODE_IP=$(/usr/local/bin/kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
if [ -z "$NODE_IP" ]; then
    send_to_chat "❌ Error: could not get the IP of the cluster node"
    exit 1
fi

WAZUH_API="https://$NODE_IP:$NODEPORT_WAZUH"

# ================= 2. Get Wazuh token =================
TOKEN=$(/usr/bin/curl -s -u "$WAZUH_USER:$WAZUH_PASS" -k -X POST "$WAZUH_API/security/user/authenticate?raw=true")
if [ -z "$TOKEN" ]; then
    send_to_chat "❌ Error: could not get Wazuh token from $WAZUH_API"
    exit 1
fi

# ================= 3. Generate random ID =================
ID=$((RANDOM * RANDOM))

# ================= 4. Send test syslog message =================
SYSLOG_MSG="<134>1 $(/usr/bin/date -u +"%Y-%m-%dT%H:%M:%SZ") testhost test-syslog - - - Test message $ID"
/usr/bin/echo "$SYSLOG_MSG" | /usr/bin/nc -w 1 "$SYSLOG_HOST" "$SYSLOG_PORT"
if [ $? -ne 0 ]; then
    send_to_chat "❌ Error: could not send syslog message to host $SYSLOG_HOST:$SYSLOG_PORT"
    exit 1
fi

# ================= 5. Search for alert in Wazuh Indexer =================
CURRENT_DATE=$(/usr/bin/date -u +"%Y.%m.%d")
CURRENT_INDEX="wazuh-alerts-4.x-$CURRENT_DATE"

QUERY_URL="$INDEXER_URL/$CURRENT_INDEX/_search?q=full_log:\"$ID\"&pretty"
RESULT=$(/usr/bin/curl -sk -u "$INDEXER_USER:$INDEXER_PASS" -X GET "$QUERY_URL")

if echo "$RESULT" | /usr/bin/grep -q '"value" : 0'; then
    send_to_chat "⚠️ Alert with ID $ID was not found in the index $CURRENT_INDEX. Possible ingestion failure."
    exit 1
else
    echo "✅ Test alert found in the index $CURRENT_INDEX. ID: $ID"
fi