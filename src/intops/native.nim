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
