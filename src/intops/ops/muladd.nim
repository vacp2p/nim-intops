## Multiplication with addition.

import ../impl/[pure, intrinsics, inlinec]

import ../consts

template wideningMulAdd*(a, b, c: uint64): tuple[hi, lo: uint64] =
  ##[ Widening multiplication + addition.

  Takes three unsigned integers and returns the product of the first two ones
  plus the third one as a pair of unsigned ints: the high word and the low word.
  ]##

  when nimvm:
    pure.wideningMulAdd(a, b, c)
  else:
    when cpu64Bit and compilerGccCompatible and canUseInlineC:
      inlinec.wideningMulAdd(a, b, c)
    elif cpu64Bit and cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.wideningMulAdd(a, b, c)
    else:
      pure.wideningMulAdd(a, b, c)

template wideningMulAdd*(a, b, c, d: uint64): tuple[hi, lo: uint64] =
  ##[ Widening multiplication + addition + addition.

  Takes four unsigned integers and returns the product of the first two ones
  plus the third one plus the fourth one as a pair of unsigned ints:
  the high word and the low word.
  ]##

  when nimvm:
    pure.wideningMulAdd(a, b, c, d)
  else:
    when cpu64Bit and compilerGccCompatible and canUseInlineC:
      inlinec.wideningMulAdd(a, b, c, d)
    elif cpu64Bit and cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.wideningMulAdd(a, b, c, d)
    else:
      pure.wideningMulAdd(a, b, c, d)
