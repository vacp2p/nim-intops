# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import ../../intops

template mulDoubleAdd2*[T: uint64 | uint32](
    a, b, c, dHi, dLo: T
): tuple[t2, r1, r0: T] =
  ##[ Calculates: (r2, r1, r0) = 2 * a * b + c + (dHi, dLo)
  Returns (r2, r1, r0) where r2 is the overflow carry (0 or 1).
  ]##

  var (r1, r0) = wideningMul(a, b)

  let (r0_new, c1) = carryingAdd(r0, r0, false)
  r0 = r0_new

  let (r1_new, c2) = carryingAdd(r1, r1, c1)
  r1 = r1_new

  var r2 = T(c2)

  let
    (sum0, c3) = carryingAdd(r0, c, false)
    (sum1, c4) = carryingAdd(r1, T(0), c3)

  r0 = sum0
  r1 = sum1
  r2 += T(c4)

  let
    (final0, c5) = carryingAdd(r0, dLo, false)
    (final1, c6) = carryingAdd(r1, dHi, c5)

  r0 = final0
  r1 = final1
  r2 += T(c6)

  (r2, r1, r0)

template mulAcc*[T: uint64 | uint32](t, u, v: T, a, b: T): tuple[t, u, v: T] =
  ##[ Calculates: (t, u, v) <- (t, u, v) + a * b
  Used for Comba multiplication column accumulation.
  ]##

  let
    (pHi, pLo) = wideningMul(a, b)
    (newV, carry1) = carryingAdd(v, pLo, false)
    (newU, carry2) = carryingAdd(u, pHi, carry1)
    newT = t + T(carry2)

  (newT, newU, newV)
