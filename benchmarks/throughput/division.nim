import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchThroughputNarrowing*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var
        hiFlush {.inject.}: typ
        loFlush {.inject.}: typ
    do:
      var
        v = inputsC[idx] or (typ(1) shl (sizeof(typ) * 8 - 1))
        uHi = inputsA[idx] and not (typ(1) shl (sizeof(typ) * 8 - 1))

      doNotOptimize(v)
      doNotOptimize(uHi)

      let (q, r) = op(uHi, inputsB[idx], v)

      hiFlush = hiFlush xor q
      loFlush = loFlush xor r
    do:
      doNotOptimize(hiFlush)
      doNotOptimize(loFlush)

proc runThroughputNarrowing() {.noinline.} =
  benchTypesAndImpls(benchThroughputNarrowing, narrowingDiv)

when isMainModule:
  echo "\n# Throughput, Narrowing Division"

  runThroughputNarrowing()
