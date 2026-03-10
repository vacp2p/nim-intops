import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

proc runLatencyOverflowing() {.noinline.} =
  benchTypesAndImpls(benchLatencyOverflowing, overflowingAdd)

proc runLatencyRaising() {.noinline.} =
  benchTypesAndImpls(benchLatencyRaising, raisingAdd)

proc runLatencyWrapping() {.noinline.} =
  benchTypesAndImpls(benchLatencyWrapping, wrappingAdd)

proc runLatencySaturating() {.noinline.} =
  benchTypesAndImpls(benchLatencySaturating, saturatingAdd)

proc runLatencyCarrying() {.noinline.} =
  benchTypesAndImpls(benchLatencyCarrying, carryingAdd)

when isMainModule:
  echo "\n# Latency, Addition"

  runLatencyOverflowing()
  runLatencyRaising()
  runLatencyWrapping()
  runLatencySaturating()
  runLatencyCarrying()
