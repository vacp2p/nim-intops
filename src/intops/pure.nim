func overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  let
    res = a + b
    didOverflow = res < a

  (res, didOverflow)

func overflowingAdd*[T: SomeSignedInt](a, b: T): (T, bool) {.inline.} =
  let
    res = T(a +% b)
    didOverflow = ((a xor b) >= 0) and ((a xor res) < 0)

  (res, didOverflow)

func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  let
    sum = a + b
    c1 = sum < a
    res = sum + T(carryIn)
    c2 = res < sum

  (res, c1 or c2)

func carryingAdd*[T: SomeSignedInt](a, b: T, carryIn: bool): (T, bool) {.inline.} =
  let
    (sum1, o1) = pure.overflowingAdd(a, b)
    (final, o2) = pure.overflowingAdd(sum1, T(carryIn))

  (final, o1 or o2)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didOverflow) = pure.carryingAdd(a, b, false)

  if unlikely(didOverflow):
    return high(T)

  res

func overflowingSub*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  let
    res = a - b
    didBorrow = a < b

  (res, didBorrow)

func overflowingSub*[T: SomeSignedInt](a, b: T): (T, bool) {.inline.} =
  let
    res = T(a -% b)
    didOverflow = ((a xor b) < 0) and ((a xor res) < 0)

  (res, didOverflow)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  let
    diff = a - b
    b1 = a < b
    res = diff - T(borrowIn)
    b2 = diff < T(borrowIn)

  (res, b1 or b2)

func borrowingSub*[T: SomeSignedInt](a, b: T, borrowIn: bool): (T, bool) {.inline.} =
  let
    (diff1, o1) = pure.overflowingSub(a, b)
    (final, o2) = pure.overflowingSub(diff1, T(borrowIn))

  (final, o1 or o2)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T {.inline.} =
  let (res, didBorrow) = pure.borrowingSub(a, b, false)

  if unlikely(didBorrow):
    return low(T)

  return res

# TODO: polish this function.
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
