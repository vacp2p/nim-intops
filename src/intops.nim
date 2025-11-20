import intops/pure
import intops/native

template overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) =
  when nimvm:
    pure.overflowingAdd(a, b)
  else:
    native.overflowingAdd(a, b)

template carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) =
  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    native.carryingAdd(a, b, carryIn)

template saturatingAdd*[T: SomeUnsignedInt](a, b: T): T =
  when nimvm:
    pure.saturatingAdd(a, b)
  else:
    native.saturatingAdd(a, b)

template overflowingSub*[T: SomeUnsignedInt](a, b: T): (T, bool) =
  when nimvm:
    pure.overflowingSub(a, b)
  else:
    native.overflowingSub(a, b)

template borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) =
  when nimvm:
    pure.borrowingSub(a, b, borrowIn)
  else:
    native.borrowingSub(a, b, borrowIn)

template saturatingSub*[T: SomeUnsignedInt](a, b: T): T =
  when nimvm:
    pure.saturatingSub(a, b)
  else:
    native.saturatingSub(a, b)

template wideningMul*(a, b: uint64): (uint64, uint64) =
  when nimvm:
    pure.wideningMul(a, b)
  else:
    native.wideningMul(a, b)
