import ../impl/[pure, intrinsics]

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
    intrinsics.overflowingSub(a, b)

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
    intrinsics.borrowingSub(a, b, borrowIn)

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
    intrinsics.saturatingSub(a, b)
