import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import utils, ../utils

proc runThroughputOverflowing() {.noinline.} =
  benchTypesAndImpls(benchThroughputOverflowing, overflowingAdd)

proc runThroughputSaturating() {.noinline.} =
  benchTypesAndImpls(benchThroughputSaturating, saturatingAdd)

proc runThroughputCarrying() {.noinline.} =
  benchTypesAndImpls(benchThroughputCarrying, carryingAdd)

when isMainModule:
  echo "\n# Throughput, Addition"

  runThroughputOverflowing()
  runThroughputSaturating()
  runThroughputCarrying()
