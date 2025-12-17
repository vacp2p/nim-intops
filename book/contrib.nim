import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
# Contributor's Guide

## Library Structure

```shell
src
│   intops.nim              <- entrypoint for the public API
│
└───intops
    │   consts.nim          <- global constants for environment detection
    │
    ├───impl                <- implementations of primitives
    │   │   inlineasm.nim   <- entrypoint for the Inline ASM family of implementations
    │   │   inlinec.nim
    │   │   intrinsics.nim
    │   │   pure.nim
    │   │
    │   ├───inlineasm
    │   │       arm64.nim   <- implementation in ARM64 Assembly 
    │   │       x86.nim
    │   │
    │   └───intrinsics
    │           gcc.nim
    │           x86.nim
    │
    └───ops                 <- operations; each module contains a family of primitives
            add.nim
            mul.nim
            sub.nim
```

The entrypoint is the root `intops` module. It exposes all the available primitives.

Each arithmetic operation has its own submodule in `intops/ops`. E.g. `intops/ops/add` is the submodule that contains various addition flavors. These submodules contain the logic to pick the best implementation of the given operation for the given CPU, OS, C compiler, and usage time. I.e., each operation "knows" its best implementation and "decides" which one to expose.

The actual implementations are stored in submodules in `intops/impl`. For example, `intops/impl/intrinsics` contains all primitives implemented with C intrinsics.

This structure allows the library to glow organically and evolve without breaking backward compatibility.

## Naming Conventions

## Improving the implementation picking logic

When you invoke a primitive, it decides which of its implementation to call with the given environment. This logic is described in templates at `intops/ops/{op}.nim`. So, to improve this logic, locate the operation and the template you want to modify and make your edits.

To define logic branches, use the global constants defined in `intops/consts.nim`. If necessary, define new constants.

When branching, prefer positive conditions to negative ones, i.e. `when cpu64Bit` is prefereble to `when not cpu32Bit`. Although they can mean virtually the same thing, the former reads better.

## Adding new implementations

In a perfect world, pure Nim implementations would be enough: the Nim compiler would generate optimal C code and the C compiler would generate the optimal Assembly code.

In reality, this is often not the case: since there are so many combinations of a Nim version, OS, CPU, and C compiler, there are performance gaps that need to be filled manually.

This is where you add a specific implementation for a primitive.

To add a new implementation of a primitive:

1. define a new function in `intops/impl/{impl}.nim`
2. update the logic that picks the best implementation in `intops/ops/{op}.nim`

For example, let's implement magic addition in C.

In `intops/impl/inlinec.nim` we add:

```nim
# This is a guard that prevents the compilation of this implementation in unsupported environments.
# In this example, we explicitly say that this implementation works only with 64-bit CPUs.
# Guards are necessary for the case where a user calls this function directly circumventing
# the logic in `ops/add.nim`.
when cpu64Bit:
  func magicAdd*(a, b: uint64): uint64 {.inline.} =
    var res: uint64

    {.
      emit:
      \"\"\"
      `res` = `a` + `b` + ((unsigned __int64)42);
      \"\"\"
    .}

    res

# If we attempt to compile this implementation in an unsupported environment, the compilation must fail.
# To make compilation fail, use this pattern: define a function with the same signature but with a single
# `error` pragma and no body.
else:
  func magicAdd*(
    a, b: uint64
  ): uint64 {.
    error:
      "Magic addition on 64-bit integers is not available on this platform."
  .}
```

In `intops/ops/add.nim`:

```nim
template magicAdd*(a, b: uint64): uint64 =
  ## Magic addition.

  # This is a very typical pattern, you'll see it everywhere. This means "if the primitive
  # is invoked during compilation, fall back to pure Nim implementation." Pure Nim implementation
  # is a universal compile-time fallback for all operations. 
  when nimvm:
    pure.wideningMul(a, b)
  else:

    # This must be at least as strict as the respective guard logic so that this code
    # is never invoked when it won't compile.
    when cpu64Bit:
      inlinec.wideningMul(a, b)

    # Again, pure Nim is a universal fallback for all cases, so you'll always see it as a final `else`.
    else:
      pure.wideningMul(a, b)
```
"""
nbSave
