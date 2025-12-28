import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchLatencyOverflowing(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        valFlush {.inject.}: typ
        ovfFlush {.inject.}: bool
    do:
      let (res, didOverflow) = op(currentA, inputsB[idx])
      ovfFlush = ovfFlush xor didOverflow
      currentA = res xor typ(ovfFlush)
      valFlush = currentA
    do:
      doNotOptimize(valFlush)
      doNotOptimize(ovfFlush)

template benchLatencySaturating(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        flush {.inject.}: typ
        currentA {.inject.} = inputsA[0]
    do:
      currentA = op(currentA, inputsB[idx])
      flush = currentA
    do:
      doNotOptimize(flush)

template benchLatencyCarrying(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), false):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), false)[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        flush {.inject.}: typ
        carryIn {.inject.}: bool
    do:
      let (res, carryOut) = op(inputsA[idx], inputsB[idx], carryIn)
      flush = res
      carryIn = carryOut
    do:
      doNotOptimize(flush)

proc runLatencyOverflowing() {.noinline.} =
  echo "\n# Latency - Overflowing"
  benchTypesAndImpls(benchLatencyOverflowing, overflowingAdd)

proc runLatencySaturating() {.noinline.} =
  echo "\n# Latency - Saturating"
  benchTypesAndImpls(benchLatencySaturating, saturatingAdd)

proc runLatencyCarrying() {.noinline.} =
  echo "\n# Latency - Carrying"
  benchTypesAndImpls(benchLatencyCarrying, carryingAdd)

when isMainModule:
  runLatencyOverflowing()
  runLatencySaturating()
  runLatencyCarrying()
