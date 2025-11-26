import std/unittest

import intops

suite "Compile time, pure Nim implementation":
  test "Overflowing addition, unsigned":
    proc testOverflowingAdd[T: SomeUnsignedInt] =
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
    proc testOverflowingAdd[T: SomeSignedInt] =
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
    proc testCarryingAdd[T: SomeUnsignedInt] =
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
    proc testSaturatingAdd[T: SomeUnsignedInt] =
      static:
        assert saturatingAdd(T(10), T(20)) == T(30)
        assert saturatingAdd(high(T) - T(1), T(1)) == high(T)
        assert saturatingAdd(high(T), T(1)) == high(T)
        assert saturatingAdd(high(T), high(T)) == high(T)
  
    testSaturatingAdd[uint8]()
    testSaturatingAdd[uint16]()
    testSaturatingAdd[uint32]()
    testSaturatingAdd[uint64]()

  test "Saturating addition, signed":
    proc testSaturatingAdd[T: SomeSignedInt] =
      static:
        assert saturatingAdd(T(10), T(20)) == T(30)
        assert saturatingAdd(high(T), T(10)) == high(T)
        assert saturatingAdd(low(T), T(-10)) == low(T)

    testSaturatingAdd[int8]()
    testSaturatingAdd[int16]()
    testSaturatingAdd[int32]()
    testSaturatingAdd[int64]()

  test "Overflowing subtraction, unsigned":
    proc testOverflowingSub[T: SomeUnsignedInt] =
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
    proc testOverflowingSub[T: SomeSignedInt] =
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
    proc testBorrowingSub[T: SomeUnsignedInt] =
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
    proc testSaturatingSub[T: SomeUnsignedInt] =
      static:
        assert saturatingSub(T(30), T(20)) == T(10)
        assert saturatingSub(low(T) + T(1), T(1)) == low(T)
        assert saturatingSub(low(T), T(1)) == low(T)
        assert saturatingSub(low(T), high(T)) == low(T)
  
    testSaturatingSub[uint8]()
    testSaturatingSub[uint16]()
    testSaturatingSub[uint32]()
    testSaturatingSub[uint64]()

  test "Saturating subtraction, signed":
    proc testSaturatingSub[T: SomeSignedInt] =
      static:
        assert saturatingSub(high(T), T(-10)) == high(T)
        assert saturatingSub(low(T), T(10)) == low(T)
  
    testSaturatingSub[int8]()
    testSaturatingSub[int16]()
    testSaturatingSub[int32]()
    testSaturatingSub[int64]()

  test "Widening multiplication, unsigned":
    proc testWideningMul[T: uint64] =
      static:
        assert wideningMul(high(T), high(T)) == (high(T) - T(1), T(1))

    testWideningMul[uint64]()

  test "Widening multiplication, signed":
    proc testWideningMul[S: int64, U: uint64] =
      static:
        assert wideningMul(high(S), S(1)) == (S(0), U(high(S)))
        assert wideningMul(S(2), S(-1)) == (S(-1), high(U) - U(1))
        assert wideningMul(S(-1), S(-1)) == (S(0), U(1))
        assert wideningMul(S(-1), S(-1)) == (S(0), U(1))
        assert wideningMul(low(S), S(-1)) == (S(0), U(high(S)) + U(1))

    testWideningMul[int64, uint64]()
    
  test "Chaining addition, carry propagation, unsigned":
    proc testChainingAddition[T: SomeUnsignedInt] =
      static:
        let
          a = [high(T), high(T), high(T)]
          b = [T(1), T(0), T(0)]

        var
          res: array[3, T]
          carry: bool

        (res[0], carry) = carryingAdd(a[0], b[0], carry)
        (res[1], carry) = carryingAdd(a[1], b[1], carry)
        (res[2], carry) = carryingAdd(a[2], b[2], carry)

        assert res == [T(0), T(0), T(0)]
        assert carry == true

    testChainingAddition[uint8]()
    testChainingAddition[uint16]()
    testChainingAddition[uint32]()
    testChainingAddition[uint64]()

  test "Chaining addition, carry kill, unsigned":
    proc testChainingAdd[T: SomeUnsignedInt] =
      static:
        let
          a = [high(T), T(0), T(0)]
          b = [T(1), T(0), T(0)]

        var
          res: array[3, T]
          carry: bool

        (res[0], carry) = carryingAdd(a[0], b[0], carry)
        (res[1], carry) = carryingAdd(a[1], b[1], carry)
        (res[2], carry) = carryingAdd(a[2], b[2], carry)

        assert res == [T(0), T(1), T(0)]
        assert carry == false

    testChainingAdd[uint8]()
    testChainingAdd[uint16]()
    testChainingAdd[uint32]()
    testChainingAdd[uint64]()

  test "Chaining subtraction, borrow propagation, unsigned":
    proc testChainingSub[T: SomeUnsignedInt] =
      static:
        let
          a = [low(T), low(T), low(T)]
          b = [T(1), T(0), T(0)]

        var
          res: array[3, T]
          borrow: bool

        (res[0], borrow) = borrowingSub(a[0], b[0], borrow)
        (res[1], borrow) = borrowingSub(a[1], b[1], borrow)
        (res[2], borrow) = borrowingSub(a[2], b[2], borrow)

        assert res == [high(T), high(T), high(T)]
        assert borrow == true

    testChainingSub[uint8]()
    testChainingSub[uint16]()
    testChainingSub[uint32]()
    testChainingSub[uint64]()

  test "Chaining subtraction, borrow absorption, unsigned":
    proc testChainingSub[T: SomeUnsignedInt] =
      static:
        let
          a = [T(0), T(1), T(0)]
          b = [T(1), T(0), T(0)]

        var
          res: array[3, T]
          borrow: bool

        (res[0], borrow) = borrowingSub(a[0], b[0], borrow)
        (res[1], borrow) = borrowingSub(a[1], b[1], borrow)
        (res[2], borrow) = borrowingSub(a[2], b[2], borrow)

        assert res == [high(T), T(0), T(0)]
        assert borrow == false

    testChainingSub[uint8]()
    testChainingSub[uint16]()
    testChainingSub[uint32]()
    testChainingSub[uint64]()
