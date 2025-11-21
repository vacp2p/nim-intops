import std/unittest

import intops

suite "Compile time, pure Nim implementation":
  test "Overflowing addition, unsigned":
    template testOverflowingAdd[T: SomeUnsignedInt]() =
      static:
        assert overflowingAdd(T(1), T(1)) == (T(2), false)
        assert overflowingAdd(high(T), T(0)) == (high(T), false)
        assert overflowingAdd(high(T), T(1)) == (T(0), true)
        assert overflowingAdd(high(T) - T(5), T(10)) == (T(4), true)

    testOverflowingAdd[uint8]()
    testOverflowingAdd[uint16]()
    testOverflowingAdd[uint32]()
    testOverflowingAdd[uint64]()

  test "Overflowing addition, signed":
    template testOverflowingAdd[T: SomeSignedInt]() =
      static:
        assert overflowingAdd(T(1), T(1)) == (T(2), false)
        assert overflowingAdd(high(T), T(-1)) == (high(T) - T(1), false)
        assert overflowingAdd(high(T), T(1)) == (low(T), true)
        assert overflowingAdd(low(T), T(-1)) == (high(T), true)

    testOverflowingAdd[int8]()
    testOverflowingAdd[int16]()
    testOverflowingAdd[int32]()
    testOverflowingAdd[int64]()

  test "Carrying addition (ADC), unsigned":
    template testCarryingAdd[T: SomeUnsignedInt]() =
      static:
        assert carryingAdd(high(T), low(T), true) == (low(T), true)
        assert carryingAdd(high(T), low(T), false) == (high(T), false)
        assert carryingAdd(high(T), high(T), true) == (high(T), true)
        assert carryingAdd(high(T), high(T), false) == (high(T) - T(1), true)

    testCarryingAdd[uint8]()
    testCarryingAdd[uint16]()
    testCarryingAdd[uint32]()
    testCarryingAdd[uint64]()

  test "Saturating addition, unsigned":
    template testSaturatingAdd[T: SomeUnsignedInt]() =
      static:
        assert saturatingAdd(T(10), T(20)) == T(30)
        assert saturatingAdd(high(T) - T(1), T(1)) == high(T)
        assert saturatingAdd(high(T), T(1)) == high(T)
        assert saturatingAdd(high(T), high(T)) == high(T)
  
    testSaturatingAdd[uint8]()
    testSaturatingAdd[uint16]()
    testSaturatingAdd[uint32]()
    testSaturatingAdd[uint64]()

  test "Overflowing subtraction, unsigned":
    template testOverflowingSub[T: SomeUnsignedInt]() =
      static:
        assert overflowingSub(T(2), T(1)) == (T(1), false)
        assert overflowingSub(T(5), T(0)) == (T(5), false)
        assert overflowingSub(T(0), T(1)) == (high(T), true)
        assert overflowingSub(T(10), T(20)) == (high(T) - T(9), true)

    testOverflowingSub[uint8]()
    testOverflowingSub[uint16]()
    testOverflowingSub[uint32]()
    testOverflowingSub[uint64]()

  test "Overflowing subtraction, signed":
    template testOverflowingSub[T: SomeSignedInt]() =
      static:
        assert overflowingSub(T(5), T(2)) == (T(3), false)
        assert overflowingSub(T(-5), T(-2)) == (T(-3), false)
        assert overflowingSub(T(10), T(-10)) == (T(20), false)
        assert overflowingSub(low(T), T(1)) == (high(T), true)
        assert overflowingSub(low(T), T(10)) == (high(T) - T(9), true)
        assert overflowingSub(high(T), T(-1)) == (low(T), true)
        assert overflowingSub(T(0), low(T)) == (low(T), true)

    testOverflowingSub[int8]()
    testOverflowingSub[int16]()
    testOverflowingSub[int32]()
    testOverflowingSub[int64]()

  test "Borrowing subtraction (SBB), unsigned":
    template testBorrowingSub[T: SomeUnsignedInt]() =
      static:
        assert borrowingSub(low(T), low(T), true) == (high(T), true)
        assert borrowingSub(low(T), low(T), false) == (low(T), false)
        assert borrowingSub(low(T), high(T), true) == (low(T), true)
        assert borrowingSub(low(T), high(T), false) == (low(T) + T(1), true)

    testBorrowingSub[uint8]()
    testBorrowingSub[uint16]()
    testBorrowingSub[uint32]()
    testBorrowingSub[uint64]()

  test "Saturating subtraction, unsigned":
    template testSaturatingSub[T: SomeUnsignedInt]() =
      static:
        assert saturatingSub(T(30), T(20)) == T(10)
        assert saturatingSub(low(T) + T(1), T(1)) == low(T)
        assert saturatingSub(low(T), T(1)) == low(T)
        assert saturatingSub(low(T), high(T)) == low(T)
  
    testSaturatingSub[uint8]()
    testSaturatingSub[uint16]()
    testSaturatingSub[uint32]()
    testSaturatingSub[uint64]()

  test "Widening multiplication, unsigned":
    static:
      let maxU = 0xFFFFFFFFFFFFFFFF'u64

      let (hi, lo) = wideningMul(maxU, maxU)

      const expectedHi = 0xFFFFFFFFFFFFFFFE'u64
      const expectedLo = 1'u64

      assert hi == expectedHi
      assert lo == expectedLo
