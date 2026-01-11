# intops
# Copyright 2025-2026 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

## CPU and compiler detection constants and compilation flags passed by the user.

const
  cpuX86* = defined(amd64) or defined(i386) ## Is the current CPU an x86 one?
  cpuArm64* = defined(arm64) or defined(aarch64) ## Is the current CPU an ARM64?
  cpu64Bit* = sizeof(int) == 8 ## Is the current CPU 64 bit?
  compilerGccCompatible* = defined(gcc) or defined(clang) or defined(llvm_gcc)
    ## Is the current C compiler compatible with GCC?
  compilerMsvc* = defined(vcc) ## Is the current C compiler MSVC?
  canUseIntrinsics* = not defined(intopsNoIntrinsics) ## C intrinsics are not forbidden.
  canUseInlineAsm* = not defined(intopsNoInlineAsm) ## Inline Assembly is not forbidden.
  canUseInlineC* = not defined(intopsNoInlineC) ## Inline C is not forbidden.
