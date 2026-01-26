import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchLatencyWidening*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        flush {.inject.}: typ
    do:
      let (hi, lo) = op(currentA, inputsB[idx])
      currentA = hi
      flush = flush xor cast[typ](lo)
    do:
      doNotOptimize(flush)

proc runLatencyWidening() {.noinline.} =
  benchTypesAndImpls(benchLatencyWidening, wideningMul)

when isMainModule:
  echo "\n# Latency, Multiplication"

  runLatencyWidening()
