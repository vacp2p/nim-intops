# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../impl/pure

template mulDoubleAdd2*[T: uint64 | uint32](
    a, b, c, dHi, dLo: T
): tuple[r2, r1, r0: T] =
  ##[ Calculates: (r2, r1, r0) = 2 * a * b + c + (dHi, dLo)

  Returns (r2, r1, r0) where r2 is the overflow carry (0 or 1).
  ]##

  pure.mulDoubleAdd2(a, b, c, dHi, dLo)

func mulAcc*[T: uint64 | uint32](t, u, v, a, b: T): tuple[t, u, v: T] =
  ##[ Calculates: (t, u, v) <- (t, u, v) + a * b

  Used for Comba multiplication column accumulation.
  ]##

  pure.mulAcc(t, u, v, a, b)
