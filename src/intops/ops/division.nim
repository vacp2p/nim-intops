# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../impl/[pure, intrinsics, inlinec, inlineasm]

import ../consts

template narrowingDiv*(uHi, uLo, v: uint64): tuple[q, r: uint64] =
  ##[ Narrowing division with remainder of an unsigned 128-bit by an unsigned 64-bit integer.

  Takes three unsigned 64-bit integers: the dividend high word, the dividend low word, and the divisor.

  Returns the quotient and the remainder.
  ]##

  when nimvm:
    pure.narrowingDiv(uHi, uLo, v)
  else:
    when cpu64Bit and cpuX86 and compilerGccCompatible and canUseInlineAsm:
      inlineasm.x86.narrowingDiv(uHi, uLo, v)
    elif cpu64Bit and compilerGccCompatible and canUseInlineC:
      inlinec.narrowingDiv(uHi, uLo, v)
    elif cpu64Bit and cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.narrowingDiv(uHi, uLo, v)
    else:
      pure.narrowingDiv(uHi, uLo, v)
