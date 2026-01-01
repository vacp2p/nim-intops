import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchLatencyNarrowing*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentHi {.inject.} = inputsA[0] shr 1
        loFlush {.inject.}: typ
    do:
      var
        v = inputsC[idx] or (typ(1) shl (sizeof(typ) * 8 - 1))
        uHi = currentHi and not (typ(1) shl (sizeof(typ) * 8 - 1))

      doNotOptimize(v)
      doNotOptimize(uHi)

      let (q, r) = op(uHi, inputsB[idx], v)

      currentHi = q + inputsA[idx]
      loFlush = loFlush xor r
    do:
      doNotOptimize(loFlush)

proc runLatencyNarrowing() {.noinline.} =
  benchTypesAndImpls(benchLatencyNarrowing, narrowingDiv)

when isMainModule:
  echo "\n# Latency, Narrowing Division"

  runLatencyNarrowing()
