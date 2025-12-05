## Intrinsics-based implementations of arithmetic operations for integers.

func overflowingAdd*[T](
  a, b: T, res: var T
): bool {.importc: "__builtin_add_overflow", nodecl.}
  ## Checks if a + b overflows. Returns true on overflow.

func overflowingSub*[T](
  a, b: T, res: var T
): bool {.importc: "__builtin_sub_overflow", nodecl.}
  ## Checks if a - b overflows. Returns true on overflow.

func overflowingAdd*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T
): (T, bool) {.inline.} =
  var res: T

  let didOverflow = overflowingAdd(a, b, res)

  (res, didOverflow)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  var res: T

  let didOverflow = overflowingAdd(a, b, res)

  if unlikely(didOverflow):
    return high(T)

  res

func carryingAdd*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T, carryIn: bool
): (T, bool) {.inline.} =
  var t1, final: T

  let
    c1 = intrinsics.overflowingAdd(a, b, t1)
    c2 = intrinsics.overflowingAdd(t1, T(carryIn), final)

  (final, c1 or c2)

func saturatingAdd*[T: SomeSignedInt](a, b: T): T {.inline.} =
  var res: T

  let didOverflow = overflowingAdd(a, b, res)

  if unlikely(didOverflow):
    if a < 0:
      return low(T)
    else:
      return high(T)

  res

func overflowingSub*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T
): (T, bool) {.inline.} =
  var res: T

  let didBorrow = overflowingSub(a, b, res)

  (res, didBorrow)

func borrowingSub*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T, borrowIn: bool
): (T, bool) {.inline.} =
  var t1, final: T

  let
    b1 = overflowingSub(a, b, t1)
    b2 = overflowingSub(t1, T(borrowIn), final)

  (final, b1 or b2)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  var res: T

  let didBorrow = overflowingSub(a, b, res)

  if unlikely(didBorrow):
    return low(T)

  res

func saturatingSub*[T: SomeSignedInt](a, b: T): T {.inline.} =
  var res: T

  let didOverflow = overflowingSub(a, b, res)

  if unlikely(didOverflow):
    if a < 0:
      return low(T)
    else:
      return high(T)

  res
