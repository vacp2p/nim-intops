import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchThroughputWidening*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var
        aFlush {.inject.}: typ
        bFlush {.inject.}: typ
    do:
      let (hi, lo) = op(inputsA[idx], inputsB[idx], inputsC[idx])
      aFlush = aFlush xor hi
      bFlush = bFlush xor cast[typ](lo)
    do:
      doNotOptimize(aFlush)
      doNotOptimize(bFlush)

proc runThroughputWidening() {.noinline.} =
  benchTypesAndImpls(benchThroughputWidening, wideningMulAdd)

when isMainModule:
  echo "\n# Throughput, Multiplication + Addition"

  runThroughputWidening()
