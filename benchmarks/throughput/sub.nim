import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

proc runThroughputOverflowing() {.noinline.} =
  benchTypesAndImpls(benchThroughputOverflowing, overflowingSub)

proc runThroughputSaturating() {.noinline.} =
  benchTypesAndImpls(benchThroughputSaturating, saturatingSub)

proc runThroughputCarrying() {.noinline.} =
  benchTypesAndImpls(benchThroughputCarrying, borrowingSub)

proc runThroughputFlag() {.noinline.} =
  benchTypesAndImpls(benchThroughputFlag, carry)

when isMainModule:
  echo "\n# Throughput, Subtraction"

  runThroughputOverflowing()
  runThroughputSaturating()
  runThroughputCarrying()
  runThroughputFlag()
