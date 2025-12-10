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

when cpu64Bit and cpuX86 and compilerGccCompatible and canUseInlineAsm:
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
