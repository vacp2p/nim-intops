## ARM64 intrinsics-based implementations of arithmetic operations for integers.

import ../../consts

when cpuArm64 and compilerGccCompatible and canUseIntrinsics:
  {.pragma: acleheader, header: "<arm_acle.h>", nodecl.}

  func saturatingAdd*(a, b: uint64): uint64 {.importc: "__uqaddl", acleheader.}

  func saturatingAdd*(a, b: uint32): uint32 {.importc: "__uqadd", acleheader.}

  func saturatingAdd*(a, b: int64): int64 {.importc: "__sqaddl", acleheader.}

  func saturatingAdd*(a, b: int32): int32 {.importc: "__sqadd", acleheader.}

  func saturatingSub*(a, b: int64): int64 {.importc: "__sqsubl", acleheader.}

  func saturatingSub*(a, b: int32): int32 {.importc: "__sqsub", acleheader.}

  func saturatingSub*(a, b: uint64): uint64 {.importc: "__uqsubl", acleheader.}

  func saturatingSub*(a, b: uint32): uint32 {.importc: "__uqsub", acleheader.}
