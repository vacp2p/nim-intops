import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchThroughputMulDoubleAdd2*(typ: typedesc, op: untyped) =
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
    measureThroughput(typ, opName):
      var
        r2Flush {.inject.}: typ
        r1Flush {.inject.}: typ
        r0Flush {.inject.}: typ
    do:
      let (r2, r1, r0) =
        op(inputsA[idx], inputsB[idx], inputsC[idx], inputsD[idx], inputsE[idx])

      r2Flush = r2Flush xor r2
      r1Flush = r1Flush xor r1
      r0Flush = r0Flush xor r0
    do:
      doNotOptimize(r2Flush)
      doNotOptimize(r1Flush)
      doNotOptimize(r0Flush)

template benchThroughputMulAcc*(typ: typedesc, op: untyped) =
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
    measureThroughput(typ, opName):
      var
        tFlush {.inject.}: typ
        uFlush {.inject.}: typ
        vFlush {.inject.}: typ
    do:
      let (t, u, v) =
        op(inputsA[idx], inputsB[idx], inputsC[idx], inputsD[idx], inputsE[idx])

      tFlush = tFlush xor t
      uFlush = uFlush xor u
      vFlush = vFlush xor v
    do:
      doNotOptimize(tFlush)
      doNotOptimize(uFlush)
      doNotOptimize(vFlush)

proc runThroughputMulDoubleAdd2() {.noinline.} =
  benchTypesAndImpls(benchThroughputMulDoubleAdd2, mulDoubleAdd2)

proc runThroughputMulAcc() {.noinline.} =
  benchTypesAndImpls(benchThroughputMulAcc, mulAcc)

when isMainModule:
  echo "\n# Throughput, Doubling Multiplication with Addition"
  runThroughputMulDoubleAdd2()

  echo "\n# Throughput, Accumulating Multiplication"
  runThroughputMulAcc()
