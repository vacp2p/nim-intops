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
      var
        flush {.inject.}: typ
        carryIn {.inject.}: bool
    do:
      let (res, carryOut) = op(inputsA[idx], inputsB[idx], carryIn)
      flush = res
      carryIn = carryOut
    do:
      doNotOptimize(flush)

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

template benchThroughputCarrying(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), false):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), false)[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var flush {.inject.}: typ
    do:
      let (res, _) = op(inputsA[idx], inputsB[idx], boolInputs[idx])
      flush = flush xor res
    do:
      doNotOptimize(flush)

template benchThroughputSaturating(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var flush {.inject.}: typ
    do:
      let res = op(inputsA[idx], inputsB[idx])
      flush = flush xor res
    do:
      doNotOptimize(flush)

template benchThroughputOverflowing(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var flush {.inject.}: typ
    do:
      let (res, didOverflow) = op(inputsA[idx], inputsB[idx])
      flush = flush xor res xor cast[typ](didOverflow)
    do:
      doNotOptimize(flush)

proc runLatencyBenchmarks =
  echo "\n# Latency benchmarks"
  benchTypesAndImpls(benchLatencyCarrying, carryingAdd)
  benchTypesAndImpls(benchLatencySaturating, saturatingAdd)
  benchTypesAndImpls(benchLatencyOverflowing, overflowingAdd)

proc runThroughputBenchmarks =
  echo "\n# Throughput benchmarks"
  benchTypesAndImpls(benchThroughputCarrying, carryingAdd)
  benchTypesAndImpls(benchThroughputSaturating, saturatingAdd)
  benchTypesAndImpls(benchThroughputOverflowing, overflowingAdd)
  
when isMainModule:
  runLatencyBenchmarks()
  runThroughputBenchmarks()
