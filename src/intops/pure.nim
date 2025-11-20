func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  ## [COMPILE-TIME PATH] Pure Nim

  let sum = a + b
  let c1 = sum < a # Did a+b wrap?
  let res = sum + T(carryIn)
  let c2 = res < sum # Did (a+b)+carry wrap?
  return (res, c1 or c2)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  ## [COMPILE-TIME PATH] Pure Nim

  let diff = a - b
  let b1 = a < b # Did a-b wrap?
  let res = diff - T(borrowIn)
  let b2 = diff < T(borrowIn) # Did (a-b)-borrow wrap?
  return (res, b1 or b2)
