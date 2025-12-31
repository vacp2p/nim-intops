import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchLatencyWidening3*(typ: typedesc, op: untyped) =
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
    do:
      let (hi, lo) = op(currentA, inputsB[idx], inputsC[idx])
      currentA = hi
      bFlush = bFlush xor cast[typ](lo)
    do:
      doNotOptimize(bFlush)

template benchLatencyWidening4*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        bFlush {.inject.}: typ
    do:
      let (hi, lo) = op(currentA, inputsB[idx], inputsC[idx], inputsD[idx])
      currentA = hi
      bFlush = bFlush xor cast[typ](lo)
    do:
      doNotOptimize(bFlush)

proc runLatencyWidening3() {.noinline.} =
  benchTypesAndImpls(benchLatencyWidening3, wideningMulAdd)

proc runLatencyWidening4() {.noinline.} =
  benchTypesAndImpls(benchLatencyWidening4, wideningMulAdd)

when isMainModule:
  echo "\n# Latency, Multiplication + Addition"
  runLatencyWidening3()

  echo "\n# Latency, Multiplication + Addition + Addition"
  runLatencyWidening4()
