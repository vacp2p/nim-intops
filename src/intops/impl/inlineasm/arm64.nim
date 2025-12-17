## Arithmetic operations for integers implemented in ARM64 GCC/Clang inline Assembly.

import ../../consts

when cpuArm64 and compilerGccCompatible and canUseInlineAsm:
  {.push inline, noinit.}

  func saturatingAdd*(a, b: uint64): uint64 =
    asm """
      uqadd %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingAdd*(a, b: uint32): uint32 =
    asm """
      uqadd %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingAdd*(a, b: int64): int64 =
    asm """
      sqadd %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingAdd*(a, b: int32): int32 =
    asm """
      sqadd %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: uint64): uint64 =
    asm """
      uqsub %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: uint32): uint32 =
    asm """
      uqsub %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: int64): int64 =
    asm """
      sqsub %d0, %d1, %d2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """

  func saturatingSub*(a, b: int32): int32 =
    asm """
      sqsub %s0, %s1, %s2
      : "=w" (`result`)
      : "w" (`a`), "w" (`b`)
    """
