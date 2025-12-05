## CPU and compiler detection constants and compilation flags passed by the user.

const
  cpuX86* = defined(amd64) or defined(i386) ## Is the current CPU an x86 one.
  cpu64Bit* = sizeof(int) == 8 ## Is the current CPU 64 bit.
  compilerGccCompatible* = defined(gcc) or defined(clang) or defined(llvm_gcc)
    ## Is the current C compiler compatible with GCC.
  noIntrinsics* = defined(intopsNoIntrinsics)
    ## Forbid usage of C intrinsics implementations.
  noInlineAsm* = defined(intopsNoInlineAsm) ## Forbid inline Assembly implementations.
  noInlineC* = defined(intopsNoInlineC) ## Forbid inline C implenentations.
