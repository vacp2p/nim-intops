import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

proc runThroughputOverflowing() {.noinline.} =
  benchTypesAndImpls(benchThroughputOverflowing, overflowingAdd)

proc runThroughputRaising() {.noinline.} =
  benchTypesAndImpls(benchThroughputRaising, raisingAdd)

proc runThroughputWrapping() {.noinline.} =
  benchTypesAndImpls(benchThroughputWrapping, wrappingAdd)

proc runThroughputSaturating() {.noinline.} =
  benchTypesAndImpls(benchThroughputSaturating, saturatingAdd)

proc runThroughputCarrying() {.noinline.} =
  benchTypesAndImpls(benchThroughputCarrying, carryingAdd)

when isMainModule:
  echo "\n# Throughput, Addition"

  runThroughputOverflowing()
  runThroughputRaising()
  runThroughputWrapping()
  runThroughputSaturating()
  runThroughputCarrying()
