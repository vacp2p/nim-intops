# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

## Intel/AMD intrinsics-based implementations of arithmetic operations for integers.

import ../../consts

when cpuX86 and canUseIntrinsics:
  when compilerMsvc:
    {.pragma: x86_header, header: "<intrin.h>", nodecl.}
  else:
    {.pragma: x86_header, header: "<x86intrin.h>", nodecl.}

  func builtinCarryingAdd*(
    carryIn: uint8, a, b: cuint, res: ptr cuint
  ): uint8 {.importc: "_addcarry_u32", x86_header.}

  func builtinBorrowingSub*(
    borrowIn: uint8, a, b: cuint, res: ptr uint32
  ): uint8 {.importc: "_subborrow_u32", x86_header.}

  {.push raises: [], inline, noinit, gcsafe.}

  func carryingAdd*(a, b: uint32, carryIn: bool): (uint32, bool) =
    var res {.noinit.}: uint32

    let carryOut =
      builtinCarryingAdd(uint8(carryIn), cuint(a), cuint(b), cast[ptr cuint](addr res))

    (res, bool(carryOut))

  func borrowingSub*(a, b: uint32, borrowIn: bool): (uint32, bool) =
    var res {.noinit.}: uint32

    let borrowOut = builtinBorrowingSub(
      uint8(borrowIn), cuint(a), cuint(b), cast[ptr cuint](addr res)
    )

    (res, bool(borrowOut))

when cpu64bit and cpuX86 and canUseIntrinsics:
  func builtinCarryingAdd*(
    carryIn: uint8, a, b: culonglong, res: ptr culonglong
  ): uint8 {.importc: "_addcarry_u64", x86_header.}

  func builtinBorrowingSub*(
    borrowIn: uint8, a, b: culonglong, res: ptr culonglong
  ): uint8 {.importc: "_subborrow_u64", x86_header.}

  {.push raises: [], inline, noinit, gcsafe.}

  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) =
    var res {.noinit.}: uint64

    let carryOut = builtinCarryingAdd(
      uint8(carryIn), culonglong(a), culonglong(b), cast[ptr culonglong](addr res)
    )

    (res, bool(carryOut))

  func borrowingSub*(a, b: uint64, borrowIn: bool): (uint64, bool) =
    var res {.noinit.}: uint64

    let borrowOut = builtinBorrowingSub(
      uint8(borrowIn), culonglong(a), culonglong(b), cast[ptr culonglong](addr res)
    )

    (res, bool(borrowOut))

when cpu64bit and cpuX86 and compilerMsvc and canUseIntrinsics:
  func builtinWideningMul*(
    a, b: culonglong, hi: ptr culonglong
  ): uint64 {.importc: "_umul128", x86_header.}

  func builtinNarrowingDiv*(
    uHi, uLo, v: culonglong, r: ptr culonglong
  ): uint64 {.importc: "_udiv128", x86_header.}

  {.push raises: [], inline, noinit, gcsafe.}

  func wideningMul*(a, b: uint64): (uint64, uint64) =
    var hi {.noinit.}: uint64

    let lo =
      builtinWideningMul(culonglong(a), culonglong(b), cast[ptr culonglong](addr hi))

    (hi, lo)

  func wideningMulAdd*(a, b, c: uint64): (uint64, uint64) =
    var
      hi, lo {.noinit.}: uint64
      carryOut {.noinit.}: uint8

    lo = builtinWideningMul(culonglong(a), culonglong(b), cast[ptr culonglong](addr hi))
    carryOut = builtinAddCarry(
      0'u8, culonglong(lo), culongculong(c), cast[prt culonglong](addr lo)
    )
    discard builtinAddCarry(
      carryOut, culonglong(hi), culonglong(0), cast[ptr culonglong](addr hi)
    )

    (hi, lo)

  func wideningMulAdd*(a, b, c, d: uint64): (uint64, uint64) =
    var
      hi, lo {.noinit.}: uint64
      carryOut1 {.noinit.}: uint8
      carryOut2 {.noinit.}: uint8

    lo = builtinWideningMul(culonglong(a), culonglong(b), cast[ptr culonglong](addr hi))
    carryOut1 = builtinAddCarry(
      0'u8, culonglong(lo), culongculong(c), cast[prt culonglong](addr lo)
    )
    discard builtinAddCarry(
      carryOut1, culonglong(hi), culonglong(0), cast[ptr culonglong](addr hi)
    )
    carryOut2 = builtinAddCarry(
      0'u8, culonglong(lo), culongculong(d), cast[prt culonglong](addr lo)
    )
    discard builtinAddCarry(
      carryOut2, culonglong(hi), culonglong(0), cast[ptr culonglong](addr hi)
    )

    (hi, lo)

  func narrowingDiv*(uHi, uLo, v: uint64): (uint64, uint64) =
    var remainder {.noinit.}: uint64

    let quotient = builtinNarrowingDiv(
      culonglong(uHi),
      culonglong(uLo),
      culonglong(v),
      cast[ptr culonglong](addr remainder),
    )

    (quotient, remainder)
