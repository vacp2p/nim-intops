import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchLatencyMulDoubleAdd2*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(
    default(typ), default(typ), default(typ), default(typ), default(typ)
  ):
    echo alignLeft(opName, 35), " -"
  elif typeof(
    op(default(typ), default(typ), default(typ), default(typ), default(typ))[0]
  ) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        r2Flush {.inject.}: typ
        r1Flush {.inject.}: typ
    do:
      let (r2, r1, r0) =
        op(currentA, inputsB[idx], inputsC[idx], inputsD[idx], inputsE[idx])

      currentA = r0 xor r1 xor r2
      r2Flush = r2Flush xor r2
      r1Flush = r1Flush xor r1
    do:
      doNotOptimize(r2Flush)
      doNotOptimize(r1Flush)

template benchLatencyMulAcc*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(
    default(typ), default(typ), default(typ), default(typ), default(typ)
  ):
    echo alignLeft(opName, 35), " -"
  elif typeof(
    op(default(typ), default(typ), default(typ), default(typ), default(typ))[0]
  ) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        uFlush {.inject.}: typ
        vFlush {.inject.}: typ
    do:
      let (t, u, v) =
        op(inputsA[idx], inputsB[idx], inputsC[idx], currentA, inputsE[idx])

      currentA = t xor u xor v
      uFlush = uFlush xor u
      vFlush = vFlush xor v
    do:
      doNotOptimize(uFlush)
      doNotOptimize(vFlush)

proc runLatencyMulDoubleAdd2() {.noinline.} =
  benchTypesAndImpls(benchLatencyMulDoubleAdd2, mulDoubleAdd2)

proc runLatencyMulAcc() {.noinline.} =
  benchTypesAndImpls(benchLatencyMulAcc, mulAcc)

when isMainModule:
  echo "\n# Latency, Doubling Multiplication with Addition"
  runLatencyMulDoubleAdd2()

  echo "\n# Latency, Accumulating Multiplication"
  runLatencyMulAcc()
