## Multiplication with addition.

import ../impl/pure

template wideningMulAdd*(a, b, c: uint64): tuple[hi, lo: uint64] =
  ##[ Widening multiplication + addition.

  Takes three unsigned integers and returns the product of the first two ones
  plus the third one as a pair of unsigned ints: the high word and the low word.
  ]##

  pure.mulAdd(a, b, c)

template wideningMulAdd*(a, b, c, d: uint64): tuple[hi, lo: uint64] =
  ##[ Widening multiplication + addition + addition.

  Takes four unsigned integers and returns the product of the first two ones
  plus the third one plus the fourth one as a pair of unsigned ints:
  the high word and the low word.
  ]##

  pure.mulAdd(a, b, c, d)
