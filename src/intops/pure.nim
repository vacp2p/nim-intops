##[ Pure Nim implementations of arithmetic operations for integers.

See the operation descriptions in `intops <../intops.html>`_ module.
]##

func overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) {.inline.} =
  let
    res = a + b
    didOverflow = res < a

  (res, didOverflow)

func overflowingAdd*[T: SomeSignedInt](a, b: T): (T, bool) {.inline.} =
  let
    res = a +% b
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
  let (res, didOverflow) = pure.overflowingAdd(a, b)

  if unlikely(didOverflow):
    return high(T)

  res

func saturatingAdd*[T: SomeSignedInt](a, b: T): T {.inline.} =
  let (res, didOverflow) = pure.overflowingAdd(a, b)

  if unlikely(didOverflow):
    if a < 0:
      return low(T)
    else:
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
  let (res, didBorrow) = pure.overflowingSub(a, b)

  if unlikely(didBorrow):
    return low(T)

  res

func saturatingSub*[T: SomeSignedInt](a, b: T): T {.inline.} =
  let (res, didOverflow) = pure.overflowingSub(a, b)

  if unlikely(didOverflow):
    if a < 0:
      return low(T)
    else:
      return high(T)

  res

func wideningMul*(a, b: uint64): (uint64, uint64) =
  const halfMask = 0xFFFFFFFF'u64

  let
    # Split inputs into 32-bit halves
    al = a and halfMask
    ah = a shr 32
    bl = b and halfMask
    bh = b shr 32

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

  (hiRes, loRes)

func wideningMul*(a, b: uint32): (uint32, uint32) {.inline.} =
  let
    res = uint64(a) * uint64(b)
    hi = uint32(res shr 32)
    lo = uint32(res)

  return (hi, lo)

func wideningMul*(a, b: int64): (int64, uint64) {.inline.} =
  let isNegative = (a < 0) xor (b < 0)

  # Absolute Values (Safe Casts)
  # We cast to uint64 to strip sign, then do 2's complement negation if needed
  let uA =
    if a < 0:
      (not cast[uint64](a)) + 1
    else:
      cast[uint64](a)
  let uB =
    if b < 0:
      (not cast[uint64](b)) + 1
    else:
      cast[uint64](b)

  var (uHi, uLo) = wideningMul(uA, uB)

  # Apply Sign to 128-bit result if needed
  if isNegative:
    uLo = (not uLo) + 1
    uHi = (not uHi)
    if uLo == 0:
      uHi = uHi + 1 # Carry propagation

  (cast[int64](uHi), uLo)

func wideningMul*(a, b: int32): (int32, uint32) {.inline.} =
  let
    res = int64(a) * int64(b)
    hi = int32(res shr 32)
    lo = uint32(res and 0xFFFFFFFF)

  return (hi, lo)

func carryingMul*[T: uint64 | uint32](a, b, carry: T): (T, T) =
  let
    (hi, lo) = pure.wideningMul(a, b)
    (loFinal, didOverflow) = pure.overflowingAdd(lo, carry)
    hiFinal = hi + T(didOverflow)

  (hiFinal, loFinal)
