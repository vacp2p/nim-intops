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

template borrowingSub*(a, b: uint64, borrow: bool): tuple[res: uint64, borrow: bool] =
  ##[ Borrowing subtraction for unsigned 64-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd <add.html#carryingAdd>`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrow)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.borrowingSub(a, b, borrow)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrow)
    elif cpu64Bit and compilerGccCompatible and canUseInlineC:
      inlinec.borrowingSub(a, b, borrow)
    else:
      pure.borrowingSub(a, b, borrow)

template borrowingSub*(a, b: uint32, borrow: bool): tuple[res: uint32, borrow: bool] =
  ##[ Borrowing subtraction for unsigned 32-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd <add.html#carryingAdd>`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrow)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.borrowingSub(a, b, borrow)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrow)
    else:
      pure.borrowingSub(a, b, borrow)

template borrowingSub*(a, b: int64, borrow: bool): tuple[res: int64, borrow: bool] =
  ##[ Borrowing subtraction for signed 64-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF):
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd <add.html#carryingAdd>`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrow)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrow)
    else:
      pure.borrowingSub(a, b, borrow)

template borrowingSub*(a, b: int32, borrow: bool): tuple[res: int32, borrow: bool] =
  ##[ Borrowing subtraction for signed 32-bit integers.

  Takes two integers and returns their difference along with the borrow flag (BF): 
  ``true`` means the previous subtraction had overflown, ``false`` means it hadn't.

  Useful for chaining operations.

  See also:
  - `carryingAdd <add.html#carryingAdd>`_
  ]##

  when nimvm:
    pure.borrowingSub(a, b, borrow)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrowingSub(a, b, borrow)
    else:
      pure.borrowingSub(a, b, borrow)

template borrow*(a, b: SomeUnsignedInt, borrow: bool): bool =
  ##[ Borrowing subtraction that returns just the borrow flag for unsigned integers.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.borrow(a, b, borrow)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.borrow(a, b, borrow)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrow(a, b, borrow)
    else:
      pure.borrow(a, b, borrow)

template borrow*(a, b: SomeSignedInt, borrow: bool): bool =
  ##[ Borrowing subtraction that returns just the borrow flag for signed integers.

  See also:
  - `borrowingSub`_
  ]##

  when nimvm:
    pure.borrow(a, b, borrow)
  else:
    when compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.borrow(a, b, borrow)
    else:
      pure.borrow(a, b, borrow)
