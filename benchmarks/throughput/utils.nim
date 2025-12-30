import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import ../utils

template benchThroughputOverflowing*(typ: typedesc, op: untyped) =
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

template benchThroughputSaturating*(typ: typedesc, op: untyped) =
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

template benchThroughputCarrying*(typ: typedesc, op: untyped) =
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
