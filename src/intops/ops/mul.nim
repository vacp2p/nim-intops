import ../impl/[pure, inlinec]
import ../consts

template wideningMul*(a, b: uint64): tuple[hi, lo: uint64] =
  ##[ Widening multiplication for unsigned integers.

  Takes two unsigned integers and returns their product as a pair of unsigned ints:
  the high word and the low word.
  ]##

  when nimvm:
    pure.wideningMul(a, b)
  else:
    when cpu64Bit and compilerGccCompatible:
      inlinec.wideningMul(a, b)
    else:
      pure.wideningMul(a, b)

template wideningMul*(a, b: uint32): tuple[hi, lo: uint32] =
  ##[ Widening multiplication for unsigned integers.

  Takes two unsigned integers and returns their product as a pair of unsigned ints:
  the high word and the low word.
  ]##

  pure.wideningMul(a, b)

template wideningMul*(a, b: int64): tuple[hi: int64, lo: uint64] =
  ##[ Widening multiplication for signed 64-bit integers.

  Takes two signed 64-bit integers and returns their product as a pair
  of a signed 64-bit high word and an unsigned 64-bit low word.
  ]##

  when nimvm:
    pure.wideningMul(a, b)
  else:
    when cpu64Bit and compilerGccCompatible:
      inlinec.wideningMul(a, b)
    else:
      pure.wideningMul(a, b)

template wideningMul*(a, b: int32): tuple[hi: int32, lo: uint32] =
  ##[ Widening multiplication for signed 32-bit integers.

  Takes two signed 32-bit integers and returns their product as a pair
  of a signed 32-bit high word and an unsigned 32-bit low word.
  ]##

  pure.wideningMul(a, b)
