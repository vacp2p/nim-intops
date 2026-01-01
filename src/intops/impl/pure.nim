## Pure Nim implementations of arithmetic operations for integers.

import std/bitops

{.push inline, noinit.}

func overflowingAdd*[T: SomeUnsignedInt](a, b: T): (T, bool) =
  let
    res = a + b
    didOverflow = res < a

  (res, didOverflow)

func overflowingAdd*[T: SomeSignedInt](a, b: T): (T, bool) =
  let
    res = a +% b
    didOverflow = ((a xor b) >= 0) and ((a xor res) < 0)

  (res, didOverflow)

func carryingAdd*[T: SomeUnsignedInt](a, b: T, carryIn: bool): (T, bool) =
  let
    sum = a + b
    c1 = sum < a
    res = sum + T(carryIn)
    c2 = res < sum

  (res, c1 or c2)

func carryingAdd*[T: SomeSignedInt](a, b: T, carryIn: bool): (T, bool) =
  let
    (sum1, o1) = pure.overflowingAdd(a, b)
    (final, o2) = pure.overflowingAdd(sum1, T(carryIn))

  (final, o1 or o2)

func saturatingAdd*[T: SomeUnsignedInt](a, b: T): T =
  let (res, didOverflow) = pure.overflowingAdd(a, b)

  if unlikely(didOverflow):
    return high(T)

  res

func saturatingAdd*[T: SomeSignedInt](a, b: T): T =
  let (res, didOverflow) = pure.overflowingAdd(a, b)

  if unlikely(didOverflow):
    if a < 0:
      return low(T)
    else:
      return high(T)

  res

func overflowingSub*[T: SomeUnsignedInt](a, b: T): (T, bool) =
  let
    res = a - b
    didBorrow = a < b

  (res, didBorrow)

func overflowingSub*[T: SomeSignedInt](a, b: T): (T, bool) =
  let
    res = T(a -% b)
    didOverflow = ((a xor b) < 0) and ((a xor res) < 0)

  (res, didOverflow)

func borrowingSub*[T: SomeUnsignedInt](a, b: T, borrowIn: bool): (T, bool) =
  let
    diff = a - b
    b1 = a < b
    res = diff - T(borrowIn)
    b2 = diff < T(borrowIn)

  (res, b1 or b2)

func borrowingSub*[T: SomeSignedInt](a, b: T, borrowIn: bool): (T, bool) =
  let
    (diff1, o1) = pure.overflowingSub(a, b)
    (final, o2) = pure.overflowingSub(diff1, T(borrowIn))

  (final, o1 or o2)

func saturatingSub*[T: SomeUnsignedInt](a, b: T): T =
  let (res, didBorrow) = pure.overflowingSub(a, b)

  if unlikely(didBorrow):
    return low(T)

  res

func saturatingSub*[T: SomeSignedInt](a, b: T): T =
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

func wideningMul*(a, b: uint32): (uint32, uint32) =
  let
    res = uint64(a) * uint64(b)
    hi = uint32(res shr 32)
    lo = uint32(res)

  return (hi, lo)

func wideningMul*(a, b: int64): (int64, uint64) =
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

func wideningMul*(a, b: int32): (int32, uint32) =
  let
    res = int64(a) * int64(b)
    hi = int32(res shr 32)
    lo = uint32(res and 0xFFFFFFFF)

  return (hi, lo)

func wideningMulAdd*(a, b, c: uint64): (uint64, uint64) =
  let
    (prodHi, prodLo) = wideningMul(a, b)
    (sumLo, carry) = carryingAdd(prodLo, c, false)
    lo = sumLo
    hi = prodHi + (if carry: 1'u64 else: 0'u64)

  (hi, lo)

func wideningMulAdd*(a, b, c, d: uint64): (uint64, uint64) =
  let
    (prodHi, prodLo) = wideningMul(a, b)
    (sumLo1, carry1) = carryingAdd(prodLo, c, false)
    (sumLo2, carry2) = carryingAdd(sumLo1, d, false)
    lo = sumLo2
    hi = prodHi + (if carry1: 1'u64 else: 0'u64) + (if carry2: 1'u64 else: 0'u64)

  (hi, lo)

func narrowingDiv*(uHi, uLo, v: uint64): (uint64, uint64) =
  ## Knuth's Algorithm D (Division of nonnegative integers) implementation.

  if v == 0:
    raise newException(DivByZeroDefect, "Division by zero")

  if uHi == 0:
    return (uLo div v, uLo mod v)

  const
    Base32 = 0x100000000'u64
    Max32 = 0xFFFFFFFF'u64

  # Normalization shift to ensure v's MSB is 1
  let shift = countLeadingZeroBits(v)

  let
    vNorm = v shl shift
    uHiNorm = (uHi shl shift) or (uLo shr (64 - shift))
    uLoNorm = uLo shl shift

  # Split normalized divisor
  let
    vHi = vNorm shr 32
    vLo = vNorm and Max32

  # Split lower part of normalized dividend
  let
    u1 = uLoNorm shr 32
    u0 = uLoNorm and Max32

  # --- High Word Calculation ---
  # Estimate qHi = uHiNorm / vHi
  var
    qHi = uHiNorm div vHi
    rHat = uHiNorm mod vHi

  # Refine qHi
  # While (qHi * vLo) > (rHat * 2^32 + u1), decrement qHi
  while qHi >= Base32 or (qHi * vLo > ((rHat shl 32) or u1)):
    qHi -= 1
    rHat += vHi
    if rHat >= Base32:
      break

  # Calculate remainder after high word: rem = (uHiNorm:u1) - qHi * vNorm
  let
    uPartialHi = (uHiNorm shl 32) or u1
    remHi = uPartialHi - qHi * vNorm

  # --- Low Word Calculation ---
  # Estimate qLo = remHi / vHi
  var qLo = remHi div vHi
  rHat = remHi mod vHi

  # Refine qLo
  while qLo >= Base32 or (qLo * vLo > ((rHat shl 32) or u0)):
    qLo -= 1
    rHat += vHi
    if rHat >= Base32:
      break

  # Calculate final remainder: rem = (remHi:u0) - qLo * vNorm
  let
    uPartialLo = (remHi shl 32) or u0
    remFinal = uPartialLo - qLo * vNorm

  # --- Denormalize ---
  let
    finalQ = (qHi shl 32) or qLo
    finalR = remFinal shr shift

  (finalQ, finalR)

func mulDoubleAdd2*[T: uint64 | uint32](a, b, c, dHi, dLo: T): (T, T, T) =
  var (r1, r0) = pure.wideningMul(a, b)

  let (r0_new, c1) = pure.carryingAdd(r0, r0, false)
  r0 = r0_new

  let (r1_new, c2) = pure.carryingAdd(r1, r1, c1)
  r1 = r1_new

  var r2 = T(c2)

  let
    (sum0, c3) = pure.carryingAdd(r0, c, false)
    (sum1, c4) = pure.carryingAdd(r1, T(0), c3)

  r0 = sum0
  r1 = sum1
  r2 += T(c4)

  let
    (final0, c5) = pure.carryingAdd(r0, dLo, false)
    (final1, c6) = pure.carryingAdd(r1, dHi, c5)

  r0 = final0
  r1 = final1
  r2 += T(c6)

  (r2, r1, r0)

func mulAcc*[T: uint64 | uint32](t, u, v: T, a, b: T): (T, T, T) =
  let
    (pHi, pLo) = pure.wideningMul(a, b)
    (newV, carry1) = pure.carryingAdd(v, pLo, false)
    (newU, carry2) = pure.carryingAdd(u, pHi, carry1)
    newT = t + (if carry2: T(1) else: T(0))

  (newT, newU, newV)
