import unittest2

import intops
from intops/impl/inlinec import nil

suite "Overflowing operations":
  test "Overflowing addition, unsigned":
    template testOverflowingAdd[T: SomeUnsignedInt]() =
      check overflowingAdd(T(1), T(1)) == (T(2), false)
      check overflowingAdd(high(T), T(0)) == (high(T), false)
      check overflowingAdd(high(T), T(1)) == (T(0), true)
      check overflowingAdd(high(T) - T(5), T(10)) == (T(4), true)

    testOverflowingAdd[uint32]()
    testOverflowingAdd[uint64]()

  test "Overflowing addition, signed":
    template testOverflowingAdd[T: SomeSignedInt]() =
      check overflowingAdd(T(1), T(1)) == (T(2), false)
      check overflowingAdd(high(T), T(-1)) == (high(T) - T(1), false)
      check overflowingAdd(high(T), T(1)) == (low(T), true)
      check overflowingAdd(low(T), T(-1)) == (high(T), true)

    testOverflowingAdd[int32]()
    testOverflowingAdd[int64]()

  test "Overflowing subtraction, unsigned":
    template testOverflowingSub[T: SomeUnsignedInt]() =
      check overflowingSub(T(2), T(1)) == (T(1), false)
      check overflowingSub(T(5), T(0)) == (T(5), false)
      check overflowingSub(T(0), T(1)) == (high(T), true)
      check overflowingSub(T(10), T(20)) == (high(T) - T(9), true)

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

    testOverflowingSub[int32]()
    testOverflowingSub[int64]()

suite "Carrying and borrowing operations":
  test "Carrying addition (ADC), unsigned":
    template testCarryingAdd[T: SomeUnsignedInt]() =
      check carryingAdd(high(T), low(T), true) == (low(T), true)
      check carryingAdd(high(T), low(T), false) == (high(T), false)
      check carryingAdd(high(T), high(T), true) == (high(T), true)
      check carryingAdd(high(T), high(T), false) == (high(T) - T(1), true)

    testCarryingAdd[uint32]()
    testCarryingAdd[uint64]()

  test "Carrying addition (ADC), signed":
    template testCarryingAdd[T: SomeSignedInt]() =
      check carryingAdd(high(T), T(0), true) == (low(T), true)
      check carryingAdd(high(T), high(T), true) == (T(-1), true)

    testCarryingAdd[int32]()
    testCarryingAdd[int64]()

  test "Borrowing subtraction (SBB), unsigned":
    template testBorrowingSub[T: SomeUnsignedInt]() =
      check borrowingSub(low(T), low(T), true) == (high(T), true)
      check borrowingSub(low(T), low(T), false) == (low(T), false)
      check borrowingSub(low(T), high(T), true) == (low(T), true)
      check borrowingSub(low(T), high(T), false) == (low(T) + T(1), true)

    testBorrowingSub[uint32]()
    testBorrowingSub[uint64]()

  test "Borrowing subtraction (SBB), signed":
    template testBorrowingSub[T: SomeSignedInt]() =
      check borrowingSub(low(T), T(0), true) == (high(T), true)
      check borrowingSub(T(10), T(5), true) == (T(4), false)

    testBorrowingSub[int32]()
    testBorrowingSub[int64]()

suite "Saturating operations":
  test "Saturating addition, unsigned":
    template testSaturatingAdd[T: SomeUnsignedInt]() =
      check saturatingAdd(T(10), T(20)) == T(30)
      check saturatingAdd(high(T) - T(1), T(1)) == high(T)
      check saturatingAdd(high(T), T(1)) == high(T)
      check saturatingAdd(high(T), high(T)) == high(T)

    testSaturatingAdd[uint32]()
    testSaturatingAdd[uint64]()

  test "Saturating addition, signed":
    template testSaturatingAdd[T: SomeSignedInt]() =
      check saturatingAdd(T(10), T(20)) == T(30)
      check saturatingAdd(high(T), T(10)) == high(T)
      check saturatingAdd(low(T), T(-10)) == low(T)

    testSaturatingAdd[int32]()
    testSaturatingAdd[int64]()

  test "Saturating subtraction, unsigned":
    template testSaturatingSub[T: SomeUnsignedInt]() =
      check saturatingSub(T(30), T(20)) == T(10)
      check saturatingSub(low(T) + T(1), T(1)) == low(T)
      check saturatingSub(low(T), T(1)) == low(T)
      check saturatingSub(low(T), high(T)) == low(T)

    testSaturatingSub[uint32]()
    testSaturatingSub[uint64]()

  test "Saturating subtraction, signed":
    template testSaturatingSub[T: SomeSignedInt]() =
      check:
        saturatingSub(high(T), T(-10)) == high(T)
        saturatingSub(low(T), T(10)) == low(T)

    testSaturatingSub[int32]()
    testSaturatingSub[int64]()

suite "Widening operations":
  test "Widening multiplication, unsigned 64-bit integers":
    when sizeof(int) == 4 and defined(intopsTestNative):
      check not compiles inlinec.wideningMul(high(uint64), high(uint64))
    else:
      check wideningMul(high(uint64), high(uint64)) == (high(uint64) - 1'u64, 1'u64)

  test "Widening multiplication, unsigned 32-bit integers":
    check wideningMul(high(uint32), high(uint32)) == (high(uint32) - 1'u32, 1'u32)

  test "Widening multiplication, signed 64-bit integers":
    when sizeof(int) == 4 and defined(intopsTestNative):
      check not compiles inlinec.wideningMul(high(int64), 1'i64)
    else:
      check wideningMul(high(int64), 1'i64) == (0'i64, uint64(high(int64)))
      check wideningMul(-1'i64, -1'i64) == (0'i64, 1'u64)
      check wideningMul(2'i64, -1'i64) == (-1'i64, high(uint64) - 1'u64)

  test "Widening multiplication, signed 32-bit integers":
    check wideningMul(high(int32), 1'i32) == (0'i32, uint32(high(int32)))
    check wideningMul(-1'i32, -1'i32) == (0'i32, 1'u32)
    check wideningMul(2'i32, -1'i32) == (-1'i32, high(uint32) - 1'u32)

  test "Widening multiplication with addition, unsigned 64-bit integers":
    check wideningMulAdd(0'u64, 0'u64, 0'u64) == (0'u64, 0'u64)
    check wideningMulAdd(2'u64, 3'u64, 4'u64) == (0'u64, 10'u64)
    check wideningMulAdd(high(uint64), 1'u64, 1'u64) == (1'u64, 0'u64)
    check wideningMulAdd(high(uint64), high(uint64), high(uint64)) ==
      (high(uint64), 0'u64)

  test "Widening multiplication with double addition, unsigned 64-bit integers":
    check wideningMulAdd(0'u64, 0'u64, 0'u64, 0'u64) == (0'u64, 0'u64)
    check wideningMulAdd(2'u64, 3'u64, 4'u64, 5'u64) == (0'u64, 15'u64)
    check wideningMulAdd(0'u64, 0'u64, high(uint64), high(uint64)) ==
      (1'u64, high(uint64) - 1'u64)
    check wideningMulAdd(high(uint64), high(uint64), high(uint64), high(uint64)) ==
      (high(uint64), high(uint64))

suite "Narrowing operations":
  test "Narrowing division, unsigned 64-bit integers":
    check narrowingDiv(0'u64, 100'u64, 10'u64) == (10'u64, 0'u64)
    check narrowingDiv(0'u64, 105'u64, 10'u64) == (10'u64, 5'u64)
    check narrowingDiv(0'u64, high(uint64), high(uint64)) == (1'u64, 0'u64)
    check narrowingDiv(1'u64, 0'u64, 2'u64) == (0x8000000000000000'u64, 0'u64)
    check narrowingDiv(1'u64, 1'u64, 2'u64) == (0x8000000000000000'u64, 1'u64)
    check narrowingDiv(1'u64, 0x800000000000000F'u64, 3'u64) ==
      (0x8000000000000005'u64, 0'u64)
    check narrowingDiv(high(uint64) - 1'u64, high(uint64) - 1'u64, high(uint64)) ==
      (high(uint64), high(uint64) - 2)

    let (q, r) = narrowingDiv(
      0xFFFFFFFEFFFFFFFF'u64, 0xFFFFFFFFFFFFFFFF'u64, 0xFFFFFFFF00000000'u64
    )

    check q == 0xFFFFFFFFFFFFFFFF'u64
    check r > 0
