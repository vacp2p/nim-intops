## Intel/AMD intrinsics-based implementations of arithmetic operations for integers.

import ../../consts

when cpuX86 and canUseIntrinsics:
  when compilerMsvc:
    {.pragma: x86_header, header: "<intrin.h>", nodecl.}
  else:
    {.pragma: x86_header, header: "<x86intrin.h>", nodecl.}

  func builtinCarryingAdd*(
    carryIn: uint8, a, b: uint32, res: var uint32
  ): uint8 {.importc: "_addcarry_u32", x86_header.}

  func builtinBorrowingSub*(
    borrowIn: uint8, a, b: uint32, res: var uint32
  ): uint8 {.importc: "_subborrow_u32", x86_header.}

  func carryingAdd*(a, b: uint32, carryIn: bool): (uint32, bool) {.inline.} =
    var sum: uint32

    let
      cIn = if carryIn: 1'u8 else: 0'u8
      cOut = builtinCarryingAdd(cIn, a, b, sum)

    (sum, cOut > 0)

  func borrowingSub*(a, b: uint32, borrowIn: bool): (uint32, bool) {.inline.} =
    var diff: uint32

    let
      bIn = if borrowIn: 1'u8 else: 0'u8
      bOut = builtinBorrowingSub(bIn, a, b, diff)

    (diff, bOut > 0)

when cpu64bit and cpuX86 and canUseIntrinsics:
  func builtinCarryingAdd*(
    carryIn: uint8, a, b: uint64, res: var uint64
  ): uint8 {.importc: "_addcarry_u64", x86_header.}

  func builtinBorrowingSub*(
    borrowIn: uint8, a, b: uint64, res: var uint64
  ): uint8 {.importc: "_subborrow_u64", x86_header.}

  func builtinNarrowingDiv*(
    uHi, uLo, v: uint64, r: var uint64
  ): uint64 {.importc: "_udiv128", x86_header.}

  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) {.inline.} =
    var sum: uint64

    let
      cIn = if carryIn: 1'u8 else: 0'u8
      cOut = builtinCarryingAdd(cIn, a, b, sum)

    (sum, cOut > 0)

  func borrowingSub*(a, b: uint64, borrowIn: bool): (uint64, bool) {.inline.} =
    var diff: uint64
    let
      bIn = if borrowIn: 1'u8 else: 0'u8
      bOut = builtinBorrowingSub(bIn, a, b, diff)

    (diff, bOut > 0)

  func narrowingDiv*(uHi, uLo, v: uint64): (uint64, uint64) {.inline.} =
    var r: uint64

    let q = builtinNarrowingDiv(uHi, uLo, v, r)

    (q, r)

when cpu64bit and cpuX86 and compilerMsvc and canUseIntrinsics:
  func builtinWideningMul*(
    a, b: uint64, hi: var uint64
  ): uint64 {.importc: "_umul128", x86_header.}

  func wideningMul*(a, b: uint64): (uint64, uint64) {.inline.} =
    var hi: uint64

    let lo = builtinWideningMul(a, b, hi)

    (hi, lo)

  func wideningMulAdd*(a, b, c: uint64): (uint64, uint64) {.inline.} =
    var
      hi, lo: uint64
      carry: uint8 = 0

    lo = builtinWideningMul(a, b, hi)
    carry = builtinAddCarry(0, lo, c, lo)
    discard builtinAddCarry(carry, hi, 0, hi)

    (hi, lo)

  func wideningMulAdd*(a, b, c, d: uint64): (uint64, uint64) {.inline.} =
    var
      hi, lo: uint64
      carry1: uint8 = 0
      carry2: uint8 = 0

    lo = builtinWideningMul(a, b, hi)
    carry1 = builtinAddCarry(0, lo, c, lo)
    discard builtinAddCarry(carry1, hi, 0, hi)
    carry2 = builtinAddCarry(0, lo, d, lo)
    discard builtinAddCarry(carry2, hi, 0, hi)

    (hi, lo)
