## Arithmetic operations for integers implemented in C.

import ../consts

when cpu64Bit and compilerGccCompatible:
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
else:
  func wideningMul*(
    a, b: uint64
  ): (uint64, uint64) {.
    error:
      "Widening multiplication on 64-bit integers is not available on this platform."
  .}

when cpu64Bit and compilerGccCompatible:
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
else:
  func wideningMul*(
    a, b: int64
  ): (int64, uint64) {.
    error:
      "Widening multiplication on 64-bit integers is not available on this platform."
  .}
