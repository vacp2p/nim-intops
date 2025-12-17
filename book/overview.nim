import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
# Overview

## Usage
"""

nbCode:
  import intops

  echo carryingAdd(12, 34, false)

nbText:
  """
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
"""

nbSave
