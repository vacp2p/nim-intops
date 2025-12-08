import ../impl/[pure, intrinsics, inlineasm]

import ../consts

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
    intrinsics.overflowingAdd(a, b)

template carryingAdd*(a, b: uint64, carryIn: bool): tuple[res: uint64, carryOut: bool] =
  ##[ Carrying addition in unsigned 64-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    when cpu64Bit and cpuX86:
      inlineasm.carryingAdd(a, b, carryIn)
    else:
      intrinsics.carryingAdd(a, b, carryIn)

template carryingAdd*(a, b: uint32, carryIn: bool): tuple[res: uint32, carryOut: bool] =
  ##[ Carrying addition in unsigned 32-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF):
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    intrinsics.carryingAdd(a, b, carryIn)

template carryingAdd*(a, b: int64, carryIn: bool): tuple[res: int64, carryOut: bool] =
  ##[ Carrying addition in signed 64-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    intrinsics.carryingAdd(a, b, carryIn)

template carryingAdd*(a, b: int32, carryIn: bool): tuple[res: int32, carryOut: bool] =
  ##[ Carrying addition in signed 32-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    intrinsics.carryingAdd(a, b, carryIn)

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
    intrinsics.saturatingAdd(a, b)
