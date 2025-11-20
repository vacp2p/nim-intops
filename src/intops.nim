import intops/pure
import intops/native

template carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) =
  ## Primitive: Add with Carry (ADC)
  ## Logic: a + b + carryIn

  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    native.carryingAdd(a, b, carryIn)

template borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) =
  ## Primitive: Subtract with Borrow (SBB)
  ## Logic: a - b - borrowIn

  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    native.borrowingSub(a, b, borrowIn)
