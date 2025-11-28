##[ Core arithmetic operations for integers:
- addition: overflowing, carrying, saturating
- subtraction: overflowing. borrowing, saturating
- multiplication: widening
]##

import intops/[pure, native]

template overflowingAdd*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T
): tuple[res: T, didOverflow: bool] =
  ##[ Overflowing addition.

  Takes two integers and returns their sum along with the overflow flag (OF):
  ``true`` means overflow happened, ``false`` means overflow didn't happen.

  Addition wraps for both signed and unsigned integers, so this operation never raises.

  See also:
  - `overflowingSub`_
  ]##

  when nimvm:
    pure.overflowingAdd(a, b)
  else:
    native.overflowingAdd(a, b)

template carryingAdd*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T, carryIn: bool
): tuple[res: T, carryOut: bool] =
  ##[ Carrying addition.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    native.carryingAdd(a, b, carryIn)

template saturatingAdd*[T: SomeUnsignedInt | SomeSignedInt](a, b: T): T =
  ##[ Saturating addition.

  Takes two integers and returns their sum; if the result won't fit within the type,
  the maximal possible value is returned.

  See also:
  - `saturatingSub`_
  ]##

  when nimvm:
    pure.saturatingAdd(a, b)
  else:
    native.saturatingAdd(a, b)

template overflowingSub*[T: SomeUnsignedInt | SomeSignedInt](a, b: T): (T, bool) =
  ##[ Overflowing subtraction.

  Takes two integers and returns their difference along with the overflow flag (OF):
  ``true`` means overflow happened, ``false`` means overflow didn't happen.

  Subtraction wraps for both signed and unsigned integers, so this operation never raises.

  See also:
  - `overflowingAdd`_
  ]##

  when nimvm:
    pure.overflowingSub(a, b)
  else:
    native.overflowingSub(a, b)

template borrowingSub*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T, borrowIn: bool
): (T, bool) =
  ##[ Borrowing subtraction.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    native.borrowingSub(a, b, borrowIn)

template saturatingSub*[T: SomeUnsignedInt | SomeSignedInt](a, b: T): T =
  ##[ Saturating subtraction.

  Takes two integers and returns their difference; if the result won't fit within the type,
  the minimal possible value is returned.

  See also:
  - `saturatingAdd`_
  ]##

  when nimvm:
    pure.saturatingSub(a, b)
  else:
    native.saturatingSub(a, b)

template wideningMul*(a, b: uint32 | uint64): tuple[hi: uint64, lo: uint64] =
  ##[ Widening multiplication for unsigned integers.

  Takes two unsigned 64-bit integers and returns their product as a pair of unsigned 64-bit ints:
  the high word and the low word.
  ]##

  when nimvm:
    pure.wideningMul(a, b)
  else:
    native.wideningMul(a, b)

template wideningMul*(a, b: uint32 | int64): tuple[hi: int64, lo: uint64] =
  ##[ Widening multiplication for signed integers.

  Takes two signed 64-bit integers and returns their product as a pair
  of a signed 64-bit high word and an unsigned 64-bit low word.
  ]##

  when nimvm:
    pure.wideningMul(a, b)
  else:
    native.wideningMul(a, b)
