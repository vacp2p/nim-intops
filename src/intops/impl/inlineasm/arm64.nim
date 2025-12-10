## Arithmetic operations for integers implemented in ARM64 Assembly.

import ../../consts

when cpuArm64 and compilerGccCompatible and canUseInlineAsm:
  func saturatingAdd*(a, b: uint64): uint64 {.inline.} =
    var res: uint64

    asm """
      uqadd %0, %1, %2
      : "=r" (res)
      : "r" (a), "r" (b)
    """

    res

  func saturatingAdd*(a, b: uint32): uint32 {.inline.} =
    var res: uint32

    asm """
      uqadd %w0, %w1, %w2
      : "=r" (res)
      : "r" (a), "r" (b)
    """

    res

  func saturatingAdd*(a, b: int64): int64 {.inline.} =
    var res: int64

    asm """
      sqadd %0, %1, %2
      : "=r" (res)
      : "r" (a), "r" (b)
    """

    res

  func saturatingAdd*(a, b: int32): int32 {.inline.} =
    var res: int32

    asm """
      sqadd %w0, %w1, %w2
      : "=r" (res)
      : "r" (a), "r" (b)
    """

    res
