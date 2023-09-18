#!/bin/bash
set -eo pipefail
CONTRACT_ADDRESS=$(
	forge create --private-key $TEST_PRIVATE_KEY --legacy src/LotteryBugRepro.sol:LotteryBugRepro --constructor-args 10 \
		| awk '/Deployed to/ {print $3}'
)
echo $CONTRACT_ADDRESS
TX_HASH=$(
	cast send $CONTRACT_ADDRESS "runLottery()"  --legacy --private-key $TEST_PRIVATE_KEY --value 1 \
		| awk '/transactionHash / {print $2}'
)
echo $TX_HASH
LOG_OUTPUT=$(curl --data "{\"jsonrpc\":\"2.0\",\"method\":\"debug_traceTransaction\", \"params\": [\"$TX_HASH\", {\"tracer\": \"callTracer\", \"timeout\": \"1000s\"}], \"id\":2}" -H "Content-Type: application/json" $ETH_RPC_URL)
echo $LOG_OUTPUT

if [[ $(echo $LOG_OUTPUT | awk '/0x0000000000000000000000000000000000001000/') ]]; then
	echo "FAIL: trace transfered to 0th address"
else
	echo "PASS"
fi
