import std/unittest

import intops

suite "Run time, intrinsics implementation":
  test "Carrying addition (ADC), unsigned":
    check carryingAdd(high(uint8), 0'u8, true) == (0'u8, true)
    check carryingAdd(high(uint16), 0'u16, true) == (0'u16, true)
    check carryingAdd(high(uint32), 0'u32, true) == (0'u32, true)
    check carryingAdd(high(uint64), 0'u64, true) == (0'u64, true)

  test "Borrowing subtraction (SBB), unsigned":
    check borrowingSub(0'u8, 0'u8, true) == (high(uint8), true)
    check borrowingSub(0'u16, 0'u16, true) == (high(uint16), true)
    check borrowingSub(0'u32, 0'u32, true) == (high(uint32), true)
    check borrowingSub(0'u64, 0'u64, true) == (high(uint64), true)

  test "Widening multiplication, unsigned":
    let maxU = 0xFFFFFFFFFFFFFFFF'u64

    let (hi, lo) = wideningMul(maxU, maxU)

    const expectedHi = 0xFFFFFFFFFFFFFFFE'u64
    const expectedLo = 1'u64

    check hi == expectedHi
    check lo == expectedLo
