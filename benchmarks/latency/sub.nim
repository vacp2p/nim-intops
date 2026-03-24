import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

proc runLatencyOverflowing() {.noinline.} =
  benchTypesAndImpls(benchLatencyOverflowing, overflowingSub)

proc runLatencySaturating() {.noinline.} =
  benchTypesAndImpls(benchLatencySaturating, saturatingSub)

proc runLatencyCarrying() {.noinline.} =
  benchTypesAndImpls(benchLatencyCarrying, borrowingSub)

proc runLatencyFlag() {.noinline.} =
  benchTypesAndImpls(benchLatencyFlag, borrow)

when isMainModule:
  echo "\n# Latency, Subtraction"

  runLatencyOverflowing()
  runLatencySaturating()
  runLatencyCarrying()
  runLatencyFlag()
