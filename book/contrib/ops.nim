import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
<span id="existing"></span>
# Improving Existing Operations

intops' public API exposes **dispatchers** for each available operation.

Dispatcher is a Nim template that contains the logic used to select the best available implementation of the given operation for the given environment.

For example, `carryingAdd` mentioned in [Quickstart](/quickstart.html) is a dispatcher.

Let's examine the code of this dispatcher:

```nim
template carryingAdd*(a, b: uint64, carryIn: bool): tuple[res: uint64, carryOut: bool] =
  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
    when cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.carryingAdd(a, b, carryIn)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.carryingAdd(a, b, carryIn)
    elif cpu64Bit and compilerGccCompatible and canUseInlineC:
      inlinec.carryingAdd(a, b, carryIn)
    else:
      pure.carryingAdd(a, b, carryIn)
```
As you can see, a dispatcher is just a nested `when`-condition that checks if:
1. the operation called during compilation (`when nimvm`)
1. the code is run on a particular CPU (`when cpuX86`) and with a particular C compiler (`and compilerMsvc`)
1. particular compilation flags were passed (`and canUseIntrinsics`)

Depending on these conditions, a particular implementation is called.

If you want to improve how intops chooses an implementation, find the corresponding dispatcher and modify the branching in it. All dispatchers are defined in `intops/ops` modules and are grouped by operation. For example, the dispatchers for addition flavors are defined in `intops/ops/add.nim`.

In the dispatchers, you can use the global constants defined in `intops/consts.nim` to check for the CPU architecture, C compiler, etc. If necessary, feel free to define new constants.

For example, if you want to prioritize inline C implementation over intrinsics, you could modify the dispatcher like so:

```diff
template carryingAdd*(a, b: uint64, carryIn: bool): tuple[res: uint64, carryOut: bool] =
  when nimvm:
    pure.carryingAdd(a, b, carryIn)
  else:
-   when cpuX86 and compilerMsvc and canUseIntrinsics:
+   when cpu64Bit and compilerGccCompatible and canUseInlineC:
+     inlinec.carryingAdd(a, b, carryIn)
+   elif cpuX86 and compilerMsvc and canUseIntrinsics:
      intrinsics.x86.carryingAdd(a, b, carryIn)
    elif compilerGccCompatible and canUseIntrinsics:
      intrinsics.gcc.carryingAdd(a, b, carryIn)
-   elif cpu64Bit and compilerGccCompatible and canUseInlineC:
-     inlinec.carryingAdd(a, b, carryIn)
    else:
      pure.carryingAdd(a, b, carryIn)
```
<span id="new"></span>
# Adding New Operations

Adding an operation means doing two things:

1. **Adding a pure Nim implementation for the new operation.** Pure Nim implementations are universal fallbacks for all operations because they are guaranteed to compile everwhere Nim code can compile regardless of the environment. Pure Nim implementations are defined in `intops/impl/pure.nim`.
1. **Adding a dispatcher that exposes this implementation.** Find the corresponding module in `intops/ops` (or create a new one) and add the dispatcher there.

For example, let's define a new addition flavor called **magic addition** which adds two uint64 integers and adds the number 42 to the sum (this is our magic component).

1. In `intops/impl/pure.nim`:

```nim
func magicAdd*(a, b: uint64): uint64 =
  a + b + 42
```

2. In `intops/ops/add.nim`:

```nim
template magicAdd*(a, b: uint64): uint64 =
  ## Docstring is mandatory for dispatchers.

  pure.magicAdd(a, b)
```

## Adding New Operation Families

If you're not just adding a new operation to an existing module but adding a new module to `intops/ops`, you must also expose it in `intops.nim` so that it becomes part of the public API.

For example, you've added a new module `intops/ops/magicadd.nim`, do this in `intops.nim`:

```diff
- import intops/ops/[add, sub, mul, muladd, division, composite]
+ import intops/ops/[add, sub, mul, muladd, division, composite, magicadd]

- export add, sub, mul, muladd, division, composite
+ export add, sub, mul, muladd, division, composite, magicadd
```
"""

nbSave
