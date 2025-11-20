import std/unittest

import intops

suite "Compile time, pure Nim implementations":
  test "Carrying addition (ADC), u8":
    static:
      assert carryingAdd(high(uint8), 0'u8, true) == (0'u8, true)
      assert carryingAdd(high(uint16), 0'u16, true) == (0'u16, true)
      assert carryingAdd(high(uint32), 0'u32, true) == (0'u32, true)
      assert carryingAdd(high(uint64), 0'u64, true) == (0'u64, true)

  test "Borrowing subtraction (SBB), u8":
    static:
      assert borrowingSub(0'u8, 0'u8, true) == (high(uint8), true)
      assert borrowingSub(0'u16, 0'u16, true) == (high(uint16), true)
      assert borrowingSub(0'u32, 0'u32, true) == (high(uint32), true)
      assert borrowingSub(0'u64, 0'u64, true) == (high(uint64), true)

  test "Widening multiplication, unsigned":
    static:
      let maxU = 0xFFFFFFFFFFFFFFFF'u64

      let (hi, lo) = wideningMul(maxU, maxU)

      const expectedHi = 0xFFFFFFFFFFFFFFFE'u64
      const expectedLo = 1'u64

      assert hi == expectedHi
      assert lo == expectedLo
