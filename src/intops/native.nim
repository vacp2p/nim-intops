import intrinsics, pure

func overflowingAdd*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T
): (T, bool) {.inline.} =
  var res: T

  let didOverflow = intrinsics.overflowingAdd(a, b, res)

  (res, didOverflow)

func carryingAdd*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T, carryIn: bool
): (T, bool) {.inline.} =
  var t1, final: T

  let
    c1 = intrinsics.overflowingAdd(a, b, t1)
    c2 = intrinsics.overflowingAdd(t1, T(carryIn), final)

  (final, c1 or c2)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  var res: T

  let didOverflow = intrinsics.overflowingAdd(a, b, res)

  if unlikely(didOverflow):
    return high(T)

  res

func saturatingAdd*[T: SomeSignedInt](a, b: T): T {.inline.} =
  var res: T

  let didOverflow = intrinsics.overflowingAdd(a, b, res)

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

  let didBorrow = intrinsics.overflowingSub(a, b, res)

  (res, didBorrow)

func borrowingSub*[T: SomeUnsignedInt | SomeSignedInt](
    a, b: T, borrowIn: bool
): (T, bool) {.inline.} =
  var t1, final: T

  let
    b1 = intrinsics.overflowingSub(a, b, t1)
    b2 = intrinsics.overflowingSub(t1, T(borrowIn), final)

  (final, b1 or b2)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  var res: T

  let didBorrow = intrinsics.overflowingSub(a, b, res)

  if unlikely(didBorrow):
    return low(T)

  res

func saturatingSub*[T: SomeSignedInt](a, b: T): T {.inline.} =
  var res: T

  let didOverflow = intrinsics.overflowingSub(a, b, res)

  if unlikely(didOverflow):
    if a < 0:
      return low(T)
    else:
      return high(T)

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

func wideningMul*(a, b: int64): (int64, uint64) {.inline.} =
  var
    hi: int64
    lo: uint64

  {.
    emit:
      """
    /* 1. Cast inputs to native C __int128 (Signed) */
    __int128 res = ((__int128)`a`) * ((__int128)`b`);

    /* 2. Extract High Word (Arithmetic Shift Right preserves sign) */
    `hi` = (long long)(res >> 64);

    /* 3. Extract Low Word (Cast to unsigned long long) */
    `lo` = (unsigned long long)(res);
  """
  .}

  (hi, lo)
