import intops/pure
import intops/native

template carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) =
  ## Primitive: Add with Carry (ADC)
  ## Logic: a + b + carryIn

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    native.carryingAdd(a, b, carryIn)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didOverflow) = intops.carryingAdd(a, b, false)

  if unlikely(didOverflow):
    return high(T)

  return res

template borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) =
  ## Primitive: Subtract with Borrow (SBB)
  ## Logic: a - b - borrowIn

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    native.borrowingSub(a, b, borrowIn)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didBorrow) = intops.borrowingSub(a, b, false)

  if unlikely(didBorrow):
    return low(T)

  return res

template wideningMul*(a, b: uint64): (uint64, uint64) =
  ## Primitive: Widening multiplication

  when nimvm:
    pure.wideningMul(a, b)
  else:
    native.wideningMul(a, b)
