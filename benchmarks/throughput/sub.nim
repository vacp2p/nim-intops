import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

proc runThroughputOverflowing() {.noinline.} =
  benchTypesAndImpls(benchThroughputOverflowing, overflowingSub)

proc runThroughputRaising() {.noinline.} =
  benchTypesAndImpls(benchThroughputRaising, raisingSub)

proc runThroughputWrapping() {.noinline.} =
  benchTypesAndImpls(benchThroughputWrapping, wrappingSub)

proc runThroughputSaturating() {.noinline.} =
  benchTypesAndImpls(benchThroughputSaturating, saturatingSub)

proc runThroughputCarrying() {.noinline.} =
  benchTypesAndImpls(benchThroughputCarrying, borrowingSub)

when isMainModule:
  echo "\n# Throughput, Subtraction"

  runThroughputOverflowing()
  runThroughputRaising()
  runThroughputWrapping()
  runThroughputSaturating()
  runThroughputCarrying()
