import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

proc runLatencyOverflowing() {.noinline.} =
  benchTypesAndImpls(benchLatencyOverflowing, overflowingAdd)

proc runLatencySaturating() {.noinline.} =
  benchTypesAndImpls(benchLatencySaturating, saturatingAdd)

proc runLatencyCarrying() {.noinline.} =
  benchTypesAndImpls(benchLatencyCarrying, carryingAdd)

proc runLatencyFlag() {.noinline.} =
  benchTypesAndImpls(benchLatencyFlag, carry)

when isMainModule:
  echo "\n# Latency, Addition"

  runLatencyOverflowing()
  runLatencySaturating()
  runLatencyCarrying()
  runLatencyFlag()
