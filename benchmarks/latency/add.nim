import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import utils, ../utils.nim

proc runLatencyOverflowing() {.noinline.} =
  benchTypesAndImpls(benchLatencyOverflowing, overflowingAdd)

proc runLatencySaturating() {.noinline.} =
  benchTypesAndImpls(benchLatencySaturating, saturatingAdd)

proc runLatencyCarrying() {.noinline.} =
  benchTypesAndImpls(benchLatencyCarrying, carryingAdd)

when isMainModule:
  echo "\n# Latency, Addition"

  runLatencyOverflowing()
  runLatencySaturating()
  runLatencyCarrying()
