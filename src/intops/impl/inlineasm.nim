## Arithmetic operations for integers implemented in x86 Assembly.

import ../consts

when not cpuX86:
  func carryingAdd*(
    a, b: uint64, carryIn: bool
  ): (uint64, bool) {.
    error:
      "ASM-based implenentation of carrying addition is not available on this platform"
  .}
else:
  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) {.inline.} =
    var
      res = a
      carryOut: uint8
      carryInUint64 = if carryIn: 1'u64 else: 0'u64

    asm """
      negq %2
      adcq %3, %0
      setc %1

      : "+r"(`res`), "=q"(`carryOut`), "+r"(`carryInUint64`)
      : "r"(`b`)
      : "cc"
    """

    (res , carryOut > 0)
