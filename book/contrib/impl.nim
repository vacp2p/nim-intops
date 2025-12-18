import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
# Adding Implementations

In a perfect world, pure Nim implementations would be enough: the Nim compiler would generate optimal C code and the C compiler would generate the optimal Assembly code.

In reality, this is often not the case: since there are so many combinations of a Nim version, OS, CPU, and C compiler, there are performance gaps that need to be filled manually.

This is where you add a specific implementation for a primitive.

To add a new implementation of a primitive:

1. define a new function in `intops/impl/{impl}.nim`
2. update the logic that picks the best implementation in `intops/ops/{op}.nim`

For example, let's implement magic addition in C.

In `intops/impl/inlinec.nim` we add:

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

In `intops/ops/add.nim`:

```nim
template magicAdd*(a, b: uint64): uint64 =
  ## Magic addition.

  # This is a very typical pattern, you'll see it everywhere. This means "if the primitive
  # is invoked during compilation, fall back to pure Nim implementation."
  # Pure Nim implementation is the universal fallback for all operations. 
  when nimvm:
    pure.wideningMul(a, b)
  else:
    # This must be at least as strict as the respective guard logic so that this code
    # is never invoked when it won't compile.
    # The `canUseInlineC` condition is there to respect the `intopsNoInlineC` compilation flag.
    when cpu64Bit and canUseInlineC:
      inlinec.wideningMul(a, b)
    else:
      pure.wideningMul(a, b)
```
"""

nbSave
