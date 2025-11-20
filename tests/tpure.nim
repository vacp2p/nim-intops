discard
  """
  action: "compile"
"""

import std/unittest

import intops

suite "Unsigned integers":
  test "Carrying addition (ADC) at compile time":
    static:
      let compileTimeResult = carryingAdd(100'u8, 20'u8, false)
      assert compileTimeResult == (120'u8, false)
