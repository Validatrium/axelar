# required "jq" installed

#replace with your rpc address: (example: localhost:26657)
RPC="localhost:26657"
TMP_FILE='/root/axelar/last-height.txt'

if [ !  -f "$TMP_FILE" ]; then
    echo 0 >  $TMP_FILE
fi

LAST_KNOWN_HEIGHT=$(cat $TMP_FILE)

LAST_HEIGHT=$(curl -s ${RPC}/status | jq '(.result.sync_info.latest_block_height | tonumber)')

if [ $LAST_KNOWN_HEIGHT -eq $LAST_HEIGHT ]; then
        echo 'Height is not changing'
        echo $LAST_HEIGHT > $TMP_FILE
        exit 1
else
        echo 'Height is ok'
        echo $LAST_HEIGHT > $TMP_FILE
        exit 0
fi
