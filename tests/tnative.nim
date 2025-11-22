import std/unittest

import intops

suite "Run time, intrinsics implementation":
  test "Overflowing addition, unsigned":
    template testOverflowingAdd[T: SomeUnsignedInt]() =
      check overflowingAdd(T(1), T(1)) == (T(2), false)
      check overflowingAdd(high(T), T(0)) == (high(T), false)
      check overflowingAdd(high(T), T(1)) == (T(0), true)
      check overflowingAdd(high(T) - T(5), T(10)) == (T(4), true)

    testOverflowingAdd[uint8]()
    testOverflowingAdd[uint16]()
    testOverflowingAdd[uint32]()
    testOverflowingAdd[uint64]()

  test "Overflowing addition, signed":
    template testOverflowingAdd[T: SomeSignedInt]() =
      check overflowingAdd(T(1), T(1)) == (T(2), false)
      check overflowingAdd(high(T), T(-1)) == (high(T) - T(1), false)
      check overflowingAdd(high(T), T(1)) == (low(T), true)
      check overflowingAdd(low(T), T(-1)) == (high(T), true)

    testOverflowingAdd[int8]()
    testOverflowingAdd[int16]()
    testOverflowingAdd[int32]()
    testOverflowingAdd[int64]()

  test "Carrying addition (ADC), unsigned":
    template testCarryingAdd[T: SomeUnsignedInt]() =
      check carryingAdd(high(T), low(T), true) == (low(T), true)
      check carryingAdd(high(T), low(T), false) == (high(T), false)
      check carryingAdd(high(T), high(T), true) == (high(T), true)
      check carryingAdd(high(T), high(T), false) == (high(T) - T(1), true)

    testCarryingAdd[uint8]()
    testCarryingAdd[uint16]()
    testCarryingAdd[uint32]()
    testCarryingAdd[uint64]()

  test "Carrying addition (ADC), signed":
    template testCarryingAdd[T: SomeSignedInt]() =
      check carryingAdd(high(T), T(0), true) == (low(T), true)
      check carryingAdd(high(T), high(T), true) == (T(-1), true)

    testCarryingAdd[int8]()
    testCarryingAdd[int16]()
    testCarryingAdd[int32]()
    testCarryingAdd[int64]()

  test "Saturating addition, unsigned":
    template testSaturatingAdd[T: SomeUnsignedInt]() =
      check saturatingAdd(T(10), T(20)) == T(30)
      check saturatingAdd(high(T) - T(1), T(1)) == high(T)
      check saturatingAdd(high(T), T(1)) == high(T)
      check saturatingAdd(high(T), high(T)) == high(T)

    testSaturatingAdd[uint8]()
    testSaturatingAdd[uint16]()
    testSaturatingAdd[uint32]()
    testSaturatingAdd[uint64]()

  test "Saturating addition, signed":
    template testSaturatingAdd[T: SomeSignedInt]() =
      check saturatingAdd(T(10), T(20)) == T(30)
      check saturatingAdd(high(T), T(10)) == high(T)
      check saturatingAdd(low(T), T(-10)) == low(T)

    testSaturatingAdd[int8]()
    testSaturatingAdd[int16]()
    testSaturatingAdd[int32]()
    testSaturatingAdd[int64]()

  test "Overflowing subtraction, unsigned":
    template testOverflowingSub[T: SomeUnsignedInt]() =
      check overflowingSub(T(2), T(1)) == (T(1), false)
      check overflowingSub(T(5), T(0)) == (T(5), false)
      check overflowingSub(T(0), T(1)) == (high(T), true)
      check overflowingSub(T(10), T(20)) == (high(T) - T(9), true)

    testOverflowingSub[uint8]()
    testOverflowingSub[uint16]()
    testOverflowingSub[uint32]()
    testOverflowingSub[uint64]()

  test "Overflowing subtraction, signed":
    template testOverflowingSub[T: SomeSignedInt]() =
      check overflowingSub(T(5), T(2)) == (T(3), false)
      check overflowingSub(T(-5), T(-2)) == (T(-3), false)
      check overflowingSub(T(10), T(-10)) == (T(20), false)
      check overflowingSub(low(T), T(1)) == (high(T), true)
      check overflowingSub(low(T), T(10)) == (high(T) - T(9), true)
      check overflowingSub(high(T), T(-1)) == (low(T), true)
      check overflowingSub(T(0), low(T)) == (low(T), true)

    testOverflowingSub[int8]()
    testOverflowingSub[int16]()
    testOverflowingSub[int32]()
    testOverflowingSub[int64]()

  test "Borrowing subtraction (SBB), unsigned":
    template testBorrowingSub[T: SomeUnsignedInt]() =
      check borrowingSub(low(T), low(T), true) == (high(T), true)
      check borrowingSub(low(T), low(T), false) == (low(T), false)
      check borrowingSub(low(T), high(T), true) == (low(T), true)
      check borrowingSub(low(T), high(T), false) == (low(T) + T(1), true)

    testBorrowingSub[uint8]()
    testBorrowingSub[uint16]()
    testBorrowingSub[uint32]()
    testBorrowingSub[uint64]()

  test "Borrowing subtraction (SBB), signed":
    template testBorrowingSub[T: SomeSignedInt]() =
      check borrowingSub(low(T), T(0), true) == (high(T), true)
      check borrowingSub(T(10), T(5), true) == (T(4), false)

    testBorrowingSub[int8]()
    testBorrowingSub[int16]()
    testBorrowingSub[int32]()
    testBorrowingSub[int64]()

  test "Saturating subtraction, unsigned":
    template testSaturatingSub[T: SomeUnsignedInt]() =
      check saturatingSub(T(30), T(20)) == T(10)
      check saturatingSub(low(T) + T(1), T(1)) == low(T)
      check saturatingSub(low(T), T(1)) == low(T)
      check saturatingSub(low(T), high(T)) == low(T)

    testSaturatingSub[uint8]()
    testSaturatingSub[uint16]()
    testSaturatingSub[uint32]()
    testSaturatingSub[uint64]()

  test "Saturating subtraction, signed":
    template testSaturatingSub[T: SomeSignedInt]() =
      check saturatingSub(high(T), T(-10)) == high(T)
      check saturatingSub(low(T), T(10)) == low(T)

    testSaturatingSub[int8]()
    testSaturatingSub[int16]()
    testSaturatingSub[int32]()
    testSaturatingSub[int64]()

  test "Widening multiplication, unsigned":
    let maxU = 0xFFFFFFFFFFFFFFFF'u64

    let (hi, lo) = wideningMul(maxU, maxU)

    const expectedHi = 0xFFFFFFFFFFFFFFFE'u64
    const expectedLo = 1'u64

    check hi == expectedHi
    check lo == expectedLo
