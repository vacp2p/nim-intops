## Arithmetic operations for integers implemented in ARM64 GCC/Clang inline Assembly.

import ../../consts

when cpuArm64 and compilerGccCompatible and canUseInlineAsm:
  func saturatingAdd*(a, b: uint64): uint64 {.inline.} =
    asm """
      uqadd %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingAdd*(a, b: uint32): uint32 {.inline.} =
    asm """
      uqadd %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingAdd*(a, b: int64): int64 {.inline.} =
    asm """
      sqadd %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingAdd*(a, b: int32): int32 {.inline.} =
    asm """
      sqadd %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: uint64): uint64 {.inline.} =
    asm """
      uqsub %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: uint32): uint32 {.inline.} =
    asm """
      uqsub %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: int64): int64 {.inline.} =
    asm """
      sqsub %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: int32): int32 {.inline.} =
    asm """
      sqsub %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """
