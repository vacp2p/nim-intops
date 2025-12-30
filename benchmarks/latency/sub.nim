import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import utils, ../utils.nim

proc runLatencyOverflowing() {.noinline.} =
  benchTypesAndImpls(benchLatencyOverflowing, overflowingSub)

proc runLatencySaturating() {.noinline.} =
  benchTypesAndImpls(benchLatencySaturating, saturatingSub)

proc runLatencyCarrying() {.noinline.} =
  benchTypesAndImpls(benchLatencyCarrying, borrowingSub)

when isMainModule:
  echo "\n# Latency, Subtraction"

  runLatencyOverflowing()
  runLatencySaturating()
  runLatencyCarrying()
