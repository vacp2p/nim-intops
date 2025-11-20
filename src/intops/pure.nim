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

func wideningMul*(a, b: uint64): (uint64, uint64) =
  ## [COMPILE-TIME PATH] Pure Nim

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
