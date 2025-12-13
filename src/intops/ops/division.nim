import ../impl/[pure, inlinec]

import ../consts

template narrowingDiv*(uHi, uLo, v: uint64): tuple[q, r: uint64] =
  ##[ Narrowing division with remainder of an unsigned 128-bit by an unsigned 64-bit integer.

  Takes three unsigned 64-bit integers: the dividend high word, the dividend low word, and the divisor.

  Returns the quontient and the remainder.
  ]##

  when nimvm:
    pure.narrowingDiv(uHi, uLo, v)
  else:
    when cpu64Bit and compilerGccCompatible and canUseInlineC:
      inlinec.narrowingDiv(uHi, uLo, v)
    else:
      pure.narrowingDiv(uHi, uLo, v)
