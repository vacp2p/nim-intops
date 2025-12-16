# intops

`intops` is a Nim library with ready-to-use core primitives for CPU-sized integers.

The library aims to satisfy the following requirements:

1. Offer a complete set of arithmetic primitives on signed and unsigned integers necessary to build bignum and cryptography-focuced libraries: addition, subtraction, multiplication, division, and composite operations.
1. Support 64- and 32-bit integers.
1. Support 64- and 32-bit CPUs.
1. Support Windows, Linux, and macOS.
1. Support GCC-compatible and MSVC compilers.
1. Support runtime and compile time usage.
1. Offer the best implementaion for each combination of CPU, OS, C compiler, and usage time.
1. Allow the user to pick the implementation manually.
1. Future addition of new operations or implementations must not require library reorganization.

Because there are so many combinations to cover, in order to keep the code maintanable and development focused, we follow these principles during development:

1. First prefer a more generic solution to a more specialized one.
2. We only test against these combinations, with runtime and compile time tests:

- amd64 + Linux + gcc 13
- amd64 + Linux + gcc 14
- amd64 + Windows + clang 19
- i386 + Linux + gcc 13
- amd64 + macOS + clang 17
- arm46 + macOS + clang 17

## Library Structure

```
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

### Future direction

If we want more granularity in the future, e.g. move each addition flavor into its own separate module, we'll just create a directory for the operation family and put all the ops in it in separate modules, while the upper-level operation module would export all operations preserving API compatibility:

```diff
intops
│
└───ops
    │   add.nim
    │
+   └───add
+           addc.nim
+           addo.nim
+           adds.nim
```

## API Docs

[API Index](https://vacp2p.github.io/nim-intops/apidocs/theindex.html)

## Usage

Operations are available in the top-level `intops` module:

```nim
import intops

let (res, carryOut) = carryingAdd(12, 34, false)
```

If you want to invoke a specific implementation, import `intops/impl/pure`, `intops/impl/intrinsics`, `intops/impl/inlinec`, or `intops/impl/inlineasm`:

```nim
import intops/impl/intrinsics

let (res, carryOut) = carryingAdd(12, 34, false)
```

## Running the tests

```shell
$ nimble test
```

## Building the docs

```shell
$ nimble docs
```

## How to contribute

### Improving the implementation picking logic

When you invoke a primitive, it decides which of its implementation to call with the given environment. This logic is described in templates at `intops/ops/{op}.nim`. So, to improve this logic, locate the operation and the template you want to modify and make your edits.

To define logic branches, use the global constants defined in `intops/consts.nim`. If necessary, define new constants.

When branching, prefer positive conditions to negative ones, i.e. `when cpu64Bit` is prefereble to `when not cpu32Bit`. Although they can mean virtually the same thing, the former reads better.

### Adding new operations

To add a new operation family:

1. create a module in `intops/ops`
2. add its import and export to `intops.nim`

To add a new operation flavor:

1. define the pure Nim implementation of this flavor in `intops/impl/pure.nim`
2. define a template for the operation in `intops/ops/{op}.nim`; the template should just invoke the pure implementation.
   For example, let's say we want to add a new kind of addition called magic addition.

In `intops/impl/pure.nim` we add:

```nim
func magicAdd*(a, b: uint64): uint64 {.inline.} =
  ## Magic addition.

  a + b + 42 # add magic
```

In `intops/ops/add.nim` we add:

```nim
template magicAdd*(a, b: uint64): uint64 =
  ## Magic addition.

  pure.magicAdd(a, b)
```

### Adding new implementations

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
      """
      `res` = `a` + `b` + ((unsigned __int64)42);
      """
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
