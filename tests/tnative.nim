import std/unittest

import intops

suite "Run time, intrinsics implementation":
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
    
  test "Widening multiplication, unsigned":
    let maxU = 0xFFFFFFFFFFFFFFFF'u64

    let (hi, lo) = wideningMul(maxU, maxU)

    const expectedHi = 0xFFFFFFFFFFFFFFFE'u64
    const expectedLo = 1'u64

    check hi == expectedHi
    check lo == expectedLo
