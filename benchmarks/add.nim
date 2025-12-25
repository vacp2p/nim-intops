import std/strutils

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import benchutils

template benchCarrying(typ: typedesc, op: untyped) =
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

echo "\n=== Carrying Add, uint64 ==="
benchCarrying(uint64, pure.carryingAdd)
benchCarrying(uint64, intrinsics.x86.carryingAdd)
benchCarrying(uint64, intrinsics.gcc.carryingAdd)
benchCarrying(uint64, inlinec.carryingAdd)
benchCarrying(uint64, inlineasm.x86.carryingAdd)
benchCarrying(uint64, inlineasm.arm64.carryingAdd)
