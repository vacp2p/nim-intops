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
