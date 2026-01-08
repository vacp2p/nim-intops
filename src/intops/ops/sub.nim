import ../impl/[pure, intrinsics, inlinec, inlineasm]

import ../consts

template overflowingSub*[T: SomeInteger](a, b: T): tuple[res: T, didOverflow: bool] =
  ##[ Overflowing subtraction.

  Takes two integers and returns their difference along with the overflow flag (OF):
  ``true`` means overflow happened, ``false`` means overflow didn't happen.

  Subtraction wraps for both signed and unsigned integers, so this operation never raises.

  See also:
  - `overflowingAdd <add.html#overflowingAdd>`_
  ]##

  when nimvm:
    pure.overflowingSub(a, b)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.overflowingSub(a, b)
    else:
      pure.overflowingSub(a, b)

template saturatingSub*[T: SomeInteger](a, b: T): T =
  ##[ Saturating subtraction.

  Takes two integers and returns their difference; if the result won't fit within the type,
  the minimal possible value is returned.

  See also:
  - `saturatingAdd <add.html#saturatingAdd>`_
  ]##

  when nimvm:
    pure.saturatingSub(a, b)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.saturatingSub(a, b)
    elif cpuArm64 and compilerGccCompatible and canUseInlineAsm:
      inlineasm.arm64.saturatingSub(a, b)
    else:
      pure.saturatingSub(a, b)

template borrowingSub*(
    a, b: uint64, borrowIn: bool
): tuple[res: uint64, borrowOut: bool] =
  ##[ Borrowing subtraction for unsigned 64-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd <add.html#carryingAdd>`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      # Intel/AMD intrinsics for MSVC (_subborrow_u64)
      intrinsics.x86.borrowingSub(a, b, borrowIn)
    elif compilerGccCompatible and canUseIntrinsics:
      # Generic GCC/Clang intrinsics otherwise (__builtin_sub_overflow)
      intrinsics.gcc.borrowingSub(a, b, borrowIn)
    elif cpu64Bit and compilerGccCompatible and canUseInlineC:
      # Inline C on 64-bit systems if builtins are unavailable
      inlinec.borrowingSub(a, b, borrowIn)
    else:
      # Universal fallback
      pure.borrowingSub(a, b, borrowIn)

template borrowingSub*(
    a, b: uint32, borrowIn: bool
): tuple[res: uint32, borrowOut: bool] =
  ##[ Borrowing subtraction for unsigned 32-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.borrowingSub(a, b, borrowIn)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrowIn)
    else:
      pure.borrowingSub(a, b, borrowIn)

template borrowingSub*(
    a, b: int64, borrowIn: bool
): tuple[res: int64, borrowOut: bool] =
  ##[ Borrowing subtraction for signed 64-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF):
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrowIn)
    else:
      pure.borrowingSub(a, b, borrowIn)

template borrowingSub*(a, b: int32, borrowIn: bool): (int32, bool) =
  ##[ Borrowing subtraction for signed 32-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrowIn)
    else:
      pure.borrowingSub(a, b, borrowIn)
