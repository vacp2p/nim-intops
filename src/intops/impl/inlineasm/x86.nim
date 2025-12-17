## Arithmetic operations for integers implemented in x86 GCC/Clang inline Assembly.

import ../../consts

when cpu64Bit and cpuX86 and compilerGccCompatible and canUseInlineAsm:
  {.push inline, noinit.}

  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) =
    var
      sum = a
      cOut: uint8
      cInVal = if carryIn: 1'u64 else: 0'u64

    asm """
      negq %[cInVal]      /* Sets CF=1 if cInVal==1, CF=0 if cInVal==0 */
      adcq %[b], %[sum]   /* sum = sum + b + CF */
      setc %[cOut]        /* Store Carry Flag (CF) into cOut */

      : [sum] "+r"(`sum`), [cOut] "=q"(`cOut`), [cInVal] "+r"(`cInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (sum, cOut > 0)

  func carryingAdd*(a, b: int64, carryIn: bool): (int64, bool) =
    var
      sum = a
      didOverflow: uint8
      cInVal = if carryIn: 1'u64 else: 0'u64

    asm """
      negq %[cInVal]      /* Sets CF based on carryIn (Standard trick) */
      adcq %[b], %[sum]   /* Signed addition is binary-identical to unsigned */
      seto %[didOverflow] /* Check OVERFLOW Flag (OF) instead of Carry */

      : [sum] "+r"(`sum`), [didOverflow] "=q"(`didOverflow`), [cInVal] "+r"(`cInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (sum, didOverflow > 0)

  func borrowingSub*(a, b: uint64, borrowIn: bool): (uint64, bool) =
    var
      diff = a
      bOut: uint8
      bInVal = if borrowIn: 1'u64 else: 0'u64

    asm """
      negq %[bInVal]      /* Sets CF=1 if bInVal==1, CF=0 if bInVal==0 */
      sbbq %[b], %[diff]  /* diff = diff - b - CF */
      setc %[bOut]        /* Store Carry Flag (CF) into bOut */

      : [diff] "+r"(`diff`), [bOut] "=q"(`bOut`), [bInVal] "+r"(`bInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (diff, bOut > 0)

  func borrowingSub*(a, b: int64, borrowIn: bool): (int64, bool) =
    var
      diff = a
      didOverflow: uint8
      bInVal = if borrowIn: 1'u64 else: 0'u64

    asm """
      negq %[bInVal]      /* Prime CF based on borrowIn */
      sbbq %[b], %[diff]  /* Signed subtraction is binary-identical to unsigned */
      seto %[didOverflow] /* Check OVERFLOW Flag (OF) for signed result validity */

      : [diff] "+r"(`diff`), [didOverflow] "=q"(`didOverflow`), [bInVal] "+r"(`bInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (diff, didOverflow > 0)

  func narrowingDiv*(uHi, uLo, v: uint64): (uint64, uint64) =
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
  {.push inline, noinit.}
  func carryingAdd*(a, b: uint32, carryIn: bool): (uint32, bool) =
    var
      sum = a
      cOut: uint8
      cInVal = if carryIn: 1'u32 else: 0'u32

    asm """
      negl %[cInVal]      /* 32-bit Negate */
      adcl %[b], %[sum]   /* 32-bit Add with Carry */
      setc %[cOut]        /* Store Carry Flag */

      : [sum] "+r"(`sum`), [cOut] "=q"(`cOut`), [cInVal] "+r"(`cInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (sum, cOut > 0)

  func carryingAdd*(a, b: int32, carryIn: bool): (int32, bool) =
    var
      sum = a
      didOverflow: uint8
      cInVal = if carryIn: 1'u32 else: 0'u32

    asm """
      negl %[cInVal]
      adcl %[b], %[sum]
      seto %[didOverflow] /* Check OVERFLOW Flag (OF) */

      : [sum] "+r"(`sum`), [didOverflow] "=q"(`didOverflow`), [cInVal] "+r"(`cInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (sum, didOverflow > 0)

  func borrowingSub*(a, b: uint32, borrowIn: bool): (uint32, bool) =
    var
      diff = a
      bOut: uint8
      bInVal = if borrowIn: 1'u32 else: 0'u32

    asm """
      negl %[bInVal]      /* 32-bit Negate to set CF */
      sbbl %[b], %[diff]  /* 32-bit Subtract with Borrow */
      setc %[bOut]        /* Store Carry Flag */

      : [diff] "+r"(`diff`), [bOut] "=q"(`bOut`), [bInVal] "+r"(`bInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (diff, bOut > 0)

  func borrowingSub*(a, b: int32, borrowIn: bool): (int32, bool) =
    var
      diff = a
      didOverflow: uint8
      bInVal = if borrowIn: 1'u32 else: 0'u32

    asm """
      negl %[bInVal]
      sbbl %[b], %[diff]
      seto %[didOverflow] /* Check OVERFLOW Flag (OF) */

      : [diff] "+r"(`diff`), [didOverflow] "=q"(`didOverflow`), [bInVal] "+r"(`bInVal`)
      : [b] "r"(`b`)
      : "cc"
    """
    (diff, didOverflow > 0)
