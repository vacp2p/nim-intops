import ../impl/[pure, intrinsics, inlinec, inlineasm]

import ../consts

template overflowingAdd*[T: SomeInteger](a, b: T): tuple[res: T, didOverflow: bool] =
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
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.overflowingAdd(a, b)
    else:
      pure.overflowingAdd(a, b)

template saturatingAdd*[T: SomeInteger](a, b: T): T =
  ##[ Saturating addition.

  Takes two integers and returns their sum; if the result won't fit within the type,
  the maximal possible value is returned.

  See also:
  - `saturatingSub`_
  ]##

  when nimvm:
    pure.saturatingAdd(a, b)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.saturatingAdd(a, b)
    elif cpuArm64 and compilerGccCompatible and canUseInlineAsm:
      inlineasm.arm64.saturatingAdd(a, b)
    else:
      pure.saturatingAdd(a, b)

template carryingAdd*(a, b: uint64, carryIn: bool): tuple[res: uint64, carryOut: bool] =
  ##[ Carrying addition for unsigned 64-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      # Intel/AMD intrinsics for MSVC (_addcarry_u64)
      intrinsics.x86.carryingAdd(a, b, carryIn)
    elif compilerGccCompatible and canUseIntrinsics:
      # Generic GCC/Clang intrinsics otherwise (__builtin_sub_overflow)
      intrinsics.gcc.carryingAdd(a, b, carryIn)
    elif cpu64Bit and compilerGccCompatible and canUseInlineC:
      # Inline C on 64-bit systems if builtins are unavailable
      inlinec.carryingAdd(a, b, carryIn)
    else:
      # Universal fallback
      pure.carryingAdd(a, b, carryIn)

template carryingAdd*(a, b: uint32, carryIn: bool): tuple[res: uint32, carryOut: bool] =
  ##[ Carrying addition for unsigned 32-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.carryingAdd(a, b, carryIn)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.carryingAdd(a, b, carryIn)
    else:
      pure.carryingAdd(a, b, carryIn)

template carryingAdd*(a, b: int64, carryIn: bool): tuple[res: int64, carryOut: bool] =
  ##[ Carrying addition for signed 64-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.carryingAdd(a, b, carryIn)
    else:
      pure.carryingAdd(a, b, carryIn)

template carryingAdd*(a, b: int32, carryIn: bool): tuple[res: int32, carryOut: bool] =
  ##[ Carrying addition for signed 32-bit integers.

  Takes two integers and returns their sum along with the carrying flag (CF): 
  ``true`` means the previous addition had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.carryingAdd(a, b, carryIn)
    else:
      pure.carryingAdd(a, b, carryIn)
