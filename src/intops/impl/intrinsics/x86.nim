## Intel/AMD intrinsics-based implementations of arithmetic operations for integers.

import ../../consts

when defined(vcc):
  {.pragma: x86_header, header: "<intrin.h>", nodecl.}
else:
  {.pragma: x86_header, header: "<x86intrin.h>", nodecl.}

when cpu64bit and cpuX86 and canUseIntrinsics:
  func builtinCarryingAdd(
    carryIn: uint8, a, b: uint64, res: var uint64
  ): uint8 {.importc: "_addcarry_u64", x86_header.}

  func builtinBorrowingSub(
    borrowIn: uint8, a, b: uint64, res: var uint64
  ): uint8 {.importc: "_subborrow_u64", x86_header.}

  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) {.inline.} =
    var sum: uint64
    let cIn = if carryIn: 1'u8 else: 0'u8
    let cOut = builtinCarryingAdd(cIn, a, b, sum)
    return (sum, cOut > 0)

when cpuX86 and canUseIntrinsics:
  func builtinCarryingAdd*(
    carryIn: uint8, a, b: uint32, res: var uint32
  ): uint8 {.importc: "_addcarry_u32", x86_header.}

  func builtinBorrowingSub*(
    borrowIn: uint8, a, b: uint32, res: var uint32
  ): uint8 {.importc: "_subborrow_u32", x86_header.}

  func carryingAdd*(a, b: uint32, carryIn: bool): (uint32, bool) {.inline.} =
    var sum: uint32
    let cIn = if carryIn: 1'u8 else: 0'u8
    let cOut = builtinCarryingAdd(cIn, a, b, sum)
    (sum, cOut > 0)
