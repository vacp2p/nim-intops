func overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  let res = a + b
  let didOverflow = res < a 
  return (res, didOverflow)

func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  let sum = a + b
  let c1 = sum < a
  let res = sum + T(carryIn)
  let c2 = res < sum
  return (res, c1 or c2)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didOverflow) = carryingAdd(a, b, false)

  if unlikely(didOverflow):
    return high(T)

  return res

func overflowingSub*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  let res = a - b
  let didBorrow = a < b
  return (res, didBorrow)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  let diff = a - b
  let b1 = a < b
  let res = diff - T(borrowIn)
  let b2 = diff < T(borrowIn)
  return (res, b1 or b2)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didBorrow) = borrowingSub(a, b, false)

  if unlikely(didBorrow):
    return low(T)

  return res

func wideningMul*(a, b: uint64): (uint64, uint64) =
  let halfMask = 0xFFFFFFFF'u64

  # Split inputs into 32-bit halves
  let al = a and halfMask
  let ah = a shr 32
  let bl = b and halfMask
  let bh = b shr 32

  # 1. Low parts multiply
  let ll = al * bl

  # 2. Cross products (the middle terms)
  let ab = al * bh
  let ba = ah * bl

  # 3. High parts multiply
  let hh = ah * bh

  # 4. Summation and Carry Handling
  # Middle term sum: ab + ba
  let mid = ab + ba
  # Check if mid overflowed (carry into high word)
  let midCarry = if mid < ab: 1'u64 else: 0'u64

  # Assemble Low 64-bit result
  # (mid << 32) + ll
  let loRes = (mid shl 32) + ll
  # Check for carry from Low to High
  let loCarry = if loRes < ll: 1'u64 else: 0'u64

  # Assemble High 64-bit result
  # hh + (mid >> 32) + midCarry + loCarry
  let hiRes = hh + (mid shr 32) + (midCarry shl 32) + loCarry

  return (hiRes, loRes)
