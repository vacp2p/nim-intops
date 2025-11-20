import intrinsics

func overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  var res: T
  let didOverflow = intrinsics.overflowingAdd(a, b, res)
  return (res, didOverflow)

func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  var t1, final: T
  let c1 = intrinsics.overflowingAdd(a, b, t1)
  let c2 = intrinsics.overflowingAdd(t1, T(carryIn), final)
  return (final, c1 or c2)

func overflowingSub*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  var res: T
  let didBorrow = intrinsics.overflowingSub(a, b, res)
  return (res, didBorrow)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  var t1, final: T
  let b1 = intrinsics.overflowingSub(a, b, t1)
  let b2 = intrinsics.overflowingSub(t1, T(borrowIn), final)
  return (final, b1 or b2)

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
  return (hi, lo)
