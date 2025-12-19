import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
<span id="existing"></span>
# Improving Existing Implementations

In a perfect world, a pure Nim implementation would be enough to cover every operation: the Nim compiler would generate the optimal C code and the C compiler would generate the optimal Assembly code for every environment.

In reality, this isn't always so. Since there are so many combinations of a Nim version, OS, CPU, and C compiler, there are inevitable performance gaps that need to be filled manually.

This is why most operations in intops have multiple implementations and dispatchers exist.

For improve an existing implementation, find its module in `intops/impl` and modify the code there. Some implementation families are represented as a single module (e.g. `intops/impl/inclinec`), some are split into submodules (e.g. `intops/intrinsics/x86.nim` and `intops/intrinsics/gcc.nim`).

<span id="new"></span>
# Adding New Implementations

If you want to provide a new implemtation for an existing operation:

1. Add a new function to the corresponsing `intops/impl` submodule (or create a new one).
1. [Update the corresponding dispatcher →](/contrib/ops.html#existing)

For example, let's implement magic addition from the previous chapter in C.

1. In `intops/impl/inlinec.nim`:

```nim
# This is a guard that prevents the compilation in unsupported environments.
# In this example, we explicitly say that this implementation works only with 64-bit CPUs.
# Guards are necessary for the case where a user calls this function directly circumventing
# the logic in `ops/add.nim`.
when cpu64Bit:
  func magicAdd*(a, b: uint64): uint64 {.inline.} =
    var res: uint64

    {. emit: "`res` = `a` + `b` + ((unsigned __int64)42);" .}

    res
```

2. In `intops/ops/add.nim`:

```diff
template magicAdd*(a, b: uint64): uint64 =
  ## Docstring is mandatory for dispatchers.

- pure.magicAdd(a, b)

+ when nimvm:
+   pure.magicAdd(a, b)
+ else:
+   when cpu64Bit and canUseInlineC:
+     inlinec.magicAdd(a, b)
+   else:
+     pure.magicAdd(a, b)
```
"""

nbSave
