# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

## Arithmetic operations for integers implemented in C.

import ../consts

when cpu64Bit and compilerGccCompatible and canUseInlineC:
  {.push inline, noinit.}

  func carryingAdd*(a, b: uint64, carryIn: bool): (uint64, bool) =
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

  func borrowingSub*(a, b: uint64, borrowIn: bool): (uint64, bool) =
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

  func wideningMul*(a, b: uint64): (uint64, uint64) =
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

  func wideningMul*(a, b: int64): (int64, uint64) =
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

  func wideningMulAdd*(a, b, c: uint64): (uint64, uint64) =
    var hi, lo: uint64
    {.
      emit:
        """
      typedef unsigned __int128 u128;

      // Calculate a * b + c using 128-bit precision
      u128 res = ((u128)`a`) * ((u128)`b`) + ((u128)`c`);

      // Split result into high and low 64-bit words
      `hi` = (unsigned long long)(res >> 64);
      `lo` = (unsigned long long)res;
    """
    .}
    (hi, lo)

  func wideningMulAdd*(a, b, c, d: uint64): (uint64, uint64) =
    var hi, lo: uint64
    {.
      emit:
        """
      typedef unsigned __int128 u128;

      // Calculate a * b + c + d using 128-bit precision
      u128 res = ((u128)`a`) * ((u128)`b`) + ((u128)`c`) + ((u128)`d`);

      // Split result
      `hi` = (unsigned long long)(res >> 64);
      `lo` = (unsigned long long)res;
    """
    .}
    (hi, lo)

  func narrowingDiv*(uHi, uLo, v: uint64): (uint64, uint64) =
    var q, r: uint64

    {.
      emit:
        """
      typedef unsigned __int128 u128;

      // Construct 128-bit integer from high/low parts
      u128 u = (((u128)`uHi`) << 64) | ((u128)`uLo`);

      // Perform Division
      `q` = (unsigned long long)(u / `v`);
      `r` = (unsigned long long)(u % `v`);
    """
    .}

    (q, r)
