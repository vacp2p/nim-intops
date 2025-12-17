## Arithmetic operations for integers implemented in ARM64 GCC/Clang inline Assembly.

import ../../consts

when cpuArm64 and compilerGccCompatible and canUseInlineAsm:
  {.push inline, noinit.}

  func saturatingAdd*(a, b: uint64): uint64 =
    asm """
      uqadd %d[result], %d[a], %d[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingAdd*(a, b: uint32): uint32 =
    asm """
      uqadd %s[result], %s[a], %s[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingAdd*(a, b: int64): int64 =
    asm """
      sqadd %d[result], %d[a], %d[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingAdd*(a, b: int32): int32 =
    asm """
      sqadd %s[result], %s[a], %s[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingSub*(a, b: uint64): uint64 =
    asm """
      uqsub %d[result], %d[a], %d[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingSub*(a, b: uint32): uint32 =
    asm """
      uqsub %s[result], %s[a], %s[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingSub*(a, b: int64): int64 =
    asm """
      sqsub %d[result], %d[a], %d[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """

  func saturatingSub*(a, b: int32): int32 =
    asm """
      sqsub %s[result], %s[a], %s[b]
      : [result] "=w" (`result`)
      : [a] "w" (`a`), [b] "w" (`b`)
    """
