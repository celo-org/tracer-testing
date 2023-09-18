# Celo Blockchain Tracer Testing

This follows the same rough structure as https://github.com/celo-org/hardfork-testing for more intricate manual testing of the blockchain tracer using mycelo and Foundry.

## Prerequisites

* [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Run mycelo

To test against mycelo, the following commands are recommended to initialize and run mycelo (executed from the celo-blockchain repo's root):

```
build/bin/mycelo genesis --buildpath compiled-system-contracts --dev.accounts 2 --newenv tmp/testenv --mnemonic "miss fire behind decide egg buyer honey seven advance uniform profit renew"
build/bin/mycelo validator-init tmp/testenv/
build/bin/mycelo validator-run tmp/testenv/
```

## Environment variables

The RPC-URL and private key have to be configured to run the test scripts. A suitable environment for mycelo (if initialized as above) is available via `source mycelo.env`. For other networks, please set the same variables to your specific values.


## Execute and trace transaction

The script `trace_runlottery.sh` will deploy `LotteryBugRepro.sol` (repros the randomness bug), executes a transaction that triggers the bug in traces, traces the resulting transaction (`debug_traceTransaction` with the `callTracer`), and prints FAIL/PASS based on whether or not the logs contain the expected transfer address.
