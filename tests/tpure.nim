import std/unittest

import intops

suite "Compile time, pure Nim implementations":
  test "Carrying addition (ADC), unsigned":
    static:
      assert carryingAdd(high(uint8), low(uint8), true) == (low(uint8), true)
      assert carryingAdd(high(uint16), low(uint16), true) == (low(uint16), true)
      assert carryingAdd(high(uint32), low(uint32), true) == (low(uint32), true)
      assert carryingAdd(high(uint64), low(uint64), true) == (low(uint64), true)

  test "Borrowing subtraction (SBB), unsigned":
    static:
      assert borrowingSub(low(uint8), low(uint8), true) == (high(uint8), true)
      assert borrowingSub(low(uint16), low(uint16), true) == (high(uint16), true)
      assert borrowingSub(low(uint32), low(uint32), true) == (high(uint32), true)
      assert borrowingSub(low(uint64), low(uint64), true) == (high(uint64), true)

  test "Widening multiplication, unsigned":
    static:
      let maxU = 0xFFFFFFFFFFFFFFFF'u64

      let (hi, lo) = wideningMul(maxU, maxU)

      const expectedHi = 0xFFFFFFFFFFFFFFFE'u64
      const expectedLo = 1'u64

      assert hi == expectedHi
      assert lo == expectedLo
