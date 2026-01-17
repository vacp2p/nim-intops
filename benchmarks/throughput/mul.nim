import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchThroughputWidening*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var
        hiFlush {.inject.}: typ
        loFlush {.inject.}: typ
    do:
      let (hi, lo) = op(inputsA[idx], inputsB[idx])
      hiFlush = hiFlush xor hi
      loFlush = loFlush xor cast[typ](lo)
    do:
      doNotOptimize(hiFlush)
      doNotOptimize(loFlush)

proc runThroughputWidening() {.noinline.} =
  benchTypesAndImpls(benchThroughputWidening, wideningMul)

when isMainModule:
  echo "\n# Throughput, Multiplication"

  runThroughputWidening()
