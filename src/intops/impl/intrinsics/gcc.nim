## GCC/Clang intrinsics-based implementations of arithmetic operations for integers.

import ../../consts

when compilerGccCompatible and canUseIntrinsics:
  func builtinOverflowingAdd*[T: SomeInteger](
    a, b: T, res: var T
  ): bool {.importc: "__builtin_add_overflow", nodecl.}
    ## Checks if a + b overflows. Returns true on overflow.

  func builtinOverflowingSub*[T: SomeInteger](
    a, b: T, res: var T
  ): bool {.importc: "__builtin_sub_overflow", nodecl.}
    ## Checks if a - b overflows. Returns true on overflow.

  {.push inline, noinit.}

  func overflowingAdd*[T: SomeInteger](a, b: T): (T, bool) =
    var res: T

    let didOverflow = builtinOverflowingAdd(a, b, res)

    (res, didOverflow)

  func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T =
    var res: T

    let didOverflow = builtinOverflowingAdd(a, b, res)

    if unlikely(didOverflow):
      return high(T)

    res

  func saturatingAdd*[T: SomeSignedInt](a, b: T): T =
    var res: T

    let didOverflow = builtinOverflowingAdd(a, b, res)

    if unlikely(didOverflow):
      if a < 0:
        return low(T)
      else:
        return high(T)

    res

  func carryingAdd*[T: SomeInteger](a, b: T, carryIn: bool): (T, bool) =
    var t1, final: T

    let
      c1 = builtinOverflowingAdd(a, b, t1)
      c2 = builtinOverflowingAdd(t1, T(carryIn), final)

    (final, c1 or c2)

  func overflowingSub*[T: SomeInteger](a, b: T): (T, bool) =
    var res: T

    let didBorrow = builtinOverflowingSub(a, b, res)

    (res, didBorrow)

  func saturatingSub*[T: SomeUnsignedInt](a, b: T): T =
    var res: T

    let didBorrow = builtinOverflowingSub(a, b, res)

    if unlikely(didBorrow):
      return low(T)

    res

  func saturatingSub*[T: SomeSignedInt](a, b: T): T =
    var res: T

    let didOverflow = builtinOverflowingSub(a, b, res)

    if unlikely(didOverflow):
      if a < 0:
        return low(T)
      else:
        return high(T)

    res

  func borrowingSub*[T: SomeInteger](a, b: T, borrowIn: bool): (T, bool) =
    var t1, final: T

    let
      b1 = builtinOverflowingSub(a, b, t1)
      b2 = builtinOverflowingSub(t1, T(borrowIn), final)

    (final, b1 or b2)
