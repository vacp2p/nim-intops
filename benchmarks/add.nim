import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import benchutils

template benchLatencyCarrying(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), false):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), false)[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var carryIn {.inject.}: bool
    do:
      let (res, carryOut) = op(inputsA[idx], inputsB[idx], carryIn)
      flush = res
      carryIn = carryOut

template benchLatencySaturating(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var currentA {.inject.} = inputsA[0]
    do:
      currentA = op(currentA, inputsB[idx])
      flush = currentA

template benchThroughputCarrying(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), false):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), false)[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      discard
    do:
      let (res, _) = op(inputsA[idx], inputsB[idx], inputsC[idx])
      flush = flush xor res

template benchThroughputSaturating(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      discard
    do:
      let res = op(inputsA[idx], inputsB[idx])
      flush = flush xor res

echo "\n# Latency benchmarks"
benchTypesAndImpls(benchLatencyCarrying, carryingAdd)
benchTypesAndImpls(benchLatencySaturating, saturatingAdd)

echo "\n# Throughput benchmarks"
benchTypesAndImpls(benchThroughputCarrying, carryingAdd)
benchTypesAndImpls(benchThroughputSaturating, saturatingAdd)
