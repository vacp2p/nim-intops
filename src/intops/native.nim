import intrinsics, pure

func overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  var res: T

  let didOverflow = intrinsics.overflowingAdd(a, b, res)

  (res, didOverflow)

func overflowingAdd*[T: SomeSignedInt](a, b: T): (T, bool) {.inline.} =
  pure.overflowingAdd(a, b)

func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  var t1, final: T

  let
    c1 = intrinsics.overflowingAdd(a, b, t1)
    c2 = intrinsics.overflowingAdd(t1, T(carryIn), final)

  (final, c1 or c2)

func carryingAdd*[T: SomeSignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  pure.carryingAdd(a, b, carryIn)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didOverflow) = native.carryingAdd(a, b, false)

  if unlikely(didOverflow):
    return high(T)

  res

func overflowingSub*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  var res: T

  let didBorrow = intrinsics.overflowingSub(a, b, res)

  (res, didBorrow)

func overflowingSub*[T: SomeSignedInt](a, b: T): (T, bool) {.inline.} =
  pure.overflowingSub(a, b)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  var t1, final: T

  let
    b1 = intrinsics.overflowingSub(a, b, t1)
    b2 = intrinsics.overflowingSub(t1, T(borrowIn), final)

  (final, b1 or b2)

func borrowingSub*[T: SomeSignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  pure.borrowingSub(a, b, borrowIn)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didBorrow) = native.borrowingSub(a, b, false)

  if unlikely(didBorrow):
    return low(T)

  res

func wideningMul*(a, b: uint64): (uint64, uint64) {.inline.} =
  var hi, lo: uint64

  {.
    emit:
      """
    /* 1. Cast inputs to 128-bit and multiply */
    unsigned __int128 res = ((unsigned __int128)`a`) * ((unsigned __int128)`b`);
    
    /* 2. Extract high 64 bits (shift right) */
    `hi` = (unsigned long long)(res >> 64);
    
    /* 3. Extract low 64 bits (cast/truncate) */
    `lo` = (unsigned long long)(res);
  """
  .}

  (hi, lo)
