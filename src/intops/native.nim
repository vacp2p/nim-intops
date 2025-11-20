import intrinsics

func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  ## [RUNTIME PATH] C Intrinsics

  var t1, final: T
  let c1 = builtin_add_overflow(a, b, t1)
  let c2 = builtin_add_overflow(t1, T(carryIn), final)
  return (final, c1 or c2)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  ## [RUNTIME PATH] C Intrinsics

  var t1, final: T
  let b1 = builtin_sub_overflow(a, b, t1)
  let b2 = builtin_sub_overflow(t1, T(borrowIn), final)
  return (final, b1 or b2)

func wideningMul*(a, b: uint64): (uint64, uint64) {.inline.} =
  ## [RUNTIME PATH] C Intrinsics

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
