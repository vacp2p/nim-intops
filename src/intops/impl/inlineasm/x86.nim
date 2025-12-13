## Arithmetic operations for integers implemented in x86 Assembly.

import ../../consts

when cpu64Bit and cpuX86 and compilerGccCompatible and canUseInlineAsm:
  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) {.inline.} =
    var
      sum = a
      cOut: uint8
      cInVal = if carryIn: 1'u64 else: 0'u64

    asm """
      negq %2      /* Sets CF=1 if cInVal==1, CF=0 if cInVal==0 */
      adcq %3, %0  /* sum = sum + b + CF */
      setc %1      /* Store Carry Flag (CF) into cOut */

      : "+r"(`sum`), "=q"(`cOut`), "+r"(`cInVal`)
      : "r"(`b`)
      : "cc"
    """
    (sum, cOut > 0)

  func carryingAdd*(a, b: int64, carryIn: bool): (int64, bool) {.inline.} =
    var
      sum = a
      didOverflow: uint8
      cInVal = if carryIn: 1'u64 else: 0'u64

    asm """
      negq %2      /* Sets CF based on carryIn (Standard trick) */
      adcq %3, %0  /* Signed addition is binary-identical to unsigned */
      seto %1      /* Check OVERFLOW Flag (OF) instead of Carry */

      : "+r"(`sum`), "=q"(`didOverflow`), "+r"(`cInVal`)
      : "r"(`b`)
      : "cc"
    """
    (sum, didOverflow > 0)

  func borrowingSub*(a, b: uint64, borrowIn: bool): (uint64, bool) {.inline.} =
    var
      diff = a
      bOut: uint8
      bInVal = if borrowIn: 1'u64 else: 0'u64

    asm """
      negq %2      /* Sets CF=1 if bInVal==1, CF=0 if bInVal==0 */
      sbbq %3, %0  /* diff = diff - b - CF */
      setc %1      /* Store Carry Flag (CF) into bOut */

      : "+r"(`diff`), "=q"(`bOut`), "+r"(`bInVal`)
      : "r"(`b`)
      : "cc"
    """
    (diff, bOut > 0)

  func borrowingSub*(a, b: int64, borrowIn: bool): (int64, bool) {.inline.} =
    var
      diff = a
      didOverflow: uint8
      bInVal = if borrowIn: 1'u64 else: 0'u64

    asm """
      negq %2      /* Prime CF based on borrowIn */
      sbbq %3, %0  /* Signed subtraction is binary-identical to unsigned */
      seto %1      /* Check OVERFLOW Flag (OF) for signed result validity */

      : "+r"(`diff`), "=q"(`didOverflow`), "+r"(`bInVal`)
      : "r"(`b`)
      : "cc"
    """
    (diff, didOverflow > 0)

  func narrowingDiv*(uHi, uLo, v: uint64): (uint64, uint64) {.inline.} =
    var q, r: uint64

    # GCC/Clang Inline Assembly
    # Instruction: divq (Unsigned Divide)
    # Inputs:
    #   Dividend High (rdx) -> uHi
    #   Dividend Low  (rax) -> uLo
    #   Divisor       (r/m) -> v
    # Outputs:
    #   Quotient      (rax) -> q
    #   Remainder     (rdx) -> r
    asm """
      divq %[v]
      : "=a" (`q`), "=d" (`r`)
      : "d" (`uHi`), "a" (`uLo`), [v] "rm" (`v`)
    """

    (q, r)

when cpuX86 and compilerGccCompatible and canUseInlineAsm:
  func carryingAdd*(a, b: uint32, carryIn: bool): (uint32, bool) {.inline.} =
    var
      sum = a
      cOut: uint8
      cInVal = if carryIn: 1'u32 else: 0'u32

    asm """
      negl %2      /* 32-bit Negate */
      adcl %3, %0  /* 32-bit Add with Carry */
      setc %1      /* Store Carry Flag */

      : "+r"(`sum`), "=q"(`cOut`), "+r"(`cInVal`)
      : "r"(`b`)
      : "cc"
    """
    (sum, cOut > 0)

  func carryingAdd*(a, b: int32, carryIn: bool): (int32, bool) {.inline.} =
    var
      sum = a
      didOverflow: uint8
      cInVal = if carryIn: 1'u32 else: 0'u32

    asm """
      negl %2
      adcl %3, %0
      seto %1      /* Check OVERFLOW Flag (OF) */

      : "+r"(`sum`), "=q"(`didOverflow`), "+r"(`cInVal`)
      : "r"(`b`)
      : "cc"
    """
    (sum, didOverflow > 0)

  func borrowingSub*(a, b: uint32, borrowIn: bool): (uint32, bool) {.inline.} =
    var
      diff = a
      bOut: uint8
      bInVal = if borrowIn: 1'u32 else: 0'u32

    asm """
      negl %2      /* 32-bit Negate to set CF */
      sbbl %3, %0  /* 32-bit Subtract with Borrow */
      setc %1      /* Store Carry Flag */

      : "+r"(`diff`), "=q"(`bOut`), "+r"(`bInVal`)
      : "r"(`b`)
      : "cc"
    """
    (diff, bOut > 0)

  func borrowingSub*(a, b: int32, borrowIn: bool): (int32, bool) {.inline.} =
    var
      diff = a
      didOverflow: uint8
      bInVal = if borrowIn: 1'u32 else: 0'u32

    asm """
      negl %2
      sbbl %3, %0
      seto %1      /* Check OVERFLOW Flag (OF) */

      : "+r"(`diff`), "=q"(`didOverflow`), "+r"(`bInVal`)
      : "r"(`b`)
      : "cc"
    """
    (diff, didOverflow > 0)
