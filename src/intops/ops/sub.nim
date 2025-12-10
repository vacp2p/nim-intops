import ../impl/[pure, intrinsics]

import ../consts

template overflowingSub*[T: SomeInteger](a, b: T): (T, bool) =
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
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.overflowingSub(a, b)
    else:
      pure.overflowingSub(a, b)

template saturatingSub*[T: SomeInteger](a, b: T): T =
  ##[ Saturating subtraction.

  Takes two integers and returns their difference; if the result won't fit within the type,
  the minimal possible value is returned.

  See also:
  - `saturatingAdd`_
  ]##

  when nimvm:
    pure.saturatingSub(a, b)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.saturatingSub(a, b)
    else:
      pure.saturatingSub(a, b)

template borrowingSub*[T: SomeInteger](a, b: T, borrowIn: bool): (T, bool) =
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
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.borrowingSub(a, b, borrowIn)
    else:
      pure.borrowingSub(a, b, borrowIn)
