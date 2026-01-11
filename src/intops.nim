# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

##[ Core arithmetic operations for integers:
- addition: overflowing, carrying, saturating
- subtraction: overflowing. borrowing, saturating
- multiplication: widening
]##

import intops/ops/[add, sub, mul, muladd, division, composite]

export add, sub, mul, muladd, division, composite
