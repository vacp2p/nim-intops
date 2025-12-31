import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchLatencyWidening*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        bFlush {.inject.}: typ
        cFlush {.inject.}: typ
    do:
      let (hi, lo) = op(currentA, inputsB[idx], inputsC[idx])
      currentA = hi
      bFlush = bFlush xor cast[typ](lo)
      cFlush = cFlush xor bFlush
    do:
      doNotOptimize(bFlush)
      doNotOptimize(cFlush)

proc runLatencyWidening() {.noinline.} =
  benchTypesAndImpls(benchLatencyWidening, wideningMulAdd)

when isMainModule:
  echo "\n# Latency, Multiplication + Addition"

  runLatencyWidening()
