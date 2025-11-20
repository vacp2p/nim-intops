import std/unittest

import intops

suite "Unsigned integers":
  test "Carrying addition (ADC)":
    let (sum, cOut) = carryingAdd(255'u8, 0'u8, true)
    check (sum, cOut) == (0'u8, true)

  test "Borrowing subtraction (SBB)":
    let (diff, bOut) = borrowingSub(0'u8, 0'u8, true)
    check (diff, bOut) == (255'u8, true)
