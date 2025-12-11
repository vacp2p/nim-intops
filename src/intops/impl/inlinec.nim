## Arithmetic operations for integers implemented in C.

import ../consts

when cpu64Bit and compilerGccCompatible and canUseInlineC:
  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) {.inline.} =
    var
      sum: uint64
      cOut: uint64 # We capture the carry as a full u64 first
      cInVal = if carryIn: 1'u64 else: 0'u64

    {.
      emit:
        """
      /* 1. Cast inputs to 128-bit and add */
      unsigned __int128 res = ((unsigned __int128)`a`) + 
                              ((unsigned __int128)`b`) + 
                              ((unsigned __int128)`cInVal`);

      /* 2. Extract the lower 64 bits (The Sum) */
      `sum` = (unsigned long long)res;

      /* 3. Extract the upper 64 bits (The Carry) */
      `cOut` = (unsigned long long)(res >> 64);
    """
    .}

    (sum, cOut > 0)

  func borrowingSub*(a, b: uint64, borrowIn: bool): (uint64, bool) {.inline.} =
    var
      diff: uint64
      bOut: uint64
      bInVal = if borrowIn: 1'u64 else: 0'u64

    {.
      emit:
        """
        /* 1. Cast inputs to 128-bit and subtract */
        /* If (a < b + borrow), 'res' wraps to a very large value (high bits become 1s) */
        unsigned __int128 res = ((unsigned __int128)`a`) -
                                ((unsigned __int128)`b`) -
                                ((unsigned __int128)`bInVal`);

        /* 2. Extract the lower 64 bits (The Difference) */
        `diff` = (unsigned long long)res;

        /* 3. Extract the upper 64 bits (The Borrow) */
        /* If a borrow occurred, the upper bits will be non-zero (specifically all 1s) */
        `bOut` = (unsigned long long)(res >> 64);
        """
    .}

    (diff, bOut > 0)

  func wideningMul*(a, b: uint64): (uint64, uint64) {.inline.} =
    var hi, lo: uint64

    {.
      emit:
        """
      /* 1. Cast inputs to 128-bit and multiply */
      unsigned __int128 res = ((unsigned __int128)`a`) * ((unsigned __int128)`b`);
  
      /* 2. Extract high 64 bits (shift right) */
      `hi` = (unsigned long long)(res >> 64);
  
      /* 3. Extract low 64 bits (cast/truncate) */
      `lo` = (unsigned long long)(res);
    """
    .}

    (hi, lo)

  func wideningMul*(a, b: int64): (int64, uint64) {.inline.} =
    var
      hi: int64
      lo: uint64

    {.
      emit:
        """
      /* 1. Cast inputs to native C __int128 (Signed) */
      __int128 res = ((__int128)`a`) * ((__int128)`b`);

      /* 2. Extract High Word (Arithmetic Shift Right preserves sign) */
      `hi` = (long long)(res >> 64);

      /* 3. Extract Low Word (Cast to unsigned long long) */
      `lo` = (unsigned long long)(res);
    """
    .}

    (hi, lo)
