import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
# Quickstart

## Installation

```shell
$ nimble install -y intops
```

Add intops to your .nimble file:

```nim
requires "intops"
```


## Usage

The most straightforward way to use intops is by importing `intops` and calling the operations from it:
"""

nbCode:
  import intops

  echo carryingAdd(12'u64, 34'u64, false)

doAssert carryingAdd(12'u64, 34'u64, false) == (46'u64, false)

nbText:
  """
`intops.carryingAdd` is a *dispatcher*. When invoked, it calls the best implementation of this operation out of the available ones for the given environment.

Notice that we call `carryingAdd` with `uint64` type set explicitly. This is important because `int` can mean different things under different circumstances and so intops doesn't allow this kind of ambiguity.

If you try to call `carryingAdd` with an `int`, your code simply won't compile: 
"""

nbCode:
  echo not compiles carryingAdd(12, 34, false)

nbText:
  """
All available dispatchers are listed in the [Imports section of the API docs for intops module](apidocs/intops.html#6).

The operations are grouped into families, each one living in a separate submodule. For example, `carryingAdd` operation mentioned above is imported from `intops/ops/add` submodule, so this is where you find its documentation: [/apidocs/intops/ops/add.html](apidocs/intops/ops/add.html#carryingAdd.t%2Cuint64%2Cuint64%2Cbool).

### Calling Specific Implementations

You may want to override the dispatcher's choice. To do that, import a particular implementation from `intops/impl` directly and call the function from it:
"""

nbCode:
  import intops/impl/intrinsics

  echo intrinsics.gcc.carryingAdd(12'u64, 34'u64, false)

nbText:
  """
Implementations are also grouped into families: pure Nim, C intrinsics, inline C, and inline Assembly. Each family can be further split into subgroups.

For example, the `carryingAdd` implementation above is based on C intrinsics that are specific to GCC/Clang. All such implementations live in [`intops/impl/intrinsics/gcc`](apidocs/intops/impl/intrinsics/gcc.html). There's also a subgroup that provides an implementation based on Intel/AMD specific C intrinsics—[`intops/impl/intrinsics/x86`](apidocs/intops/impl/intrinsics/x86.html).

To see all available implementations for a particular operation, find it in the [API index](apidocs/theindex.html#carryingAdd).

#### Caveat

When you use a dispatcher, you can be sure that your code will compile in any environment. It is the dispatcher's job to provide a code path for any case, so you don't have to worry about it.

But if you choose to call an implementation manually, it is your job to validate that this implementation is available in the environment you're using it in. If you attempt to use an implementation that is unavailable, you'll get a compile-time error.

For example, trying to use an Inline Assembly implementation with `intopsNoInlineAsm` flag (more on those in the section below) will cause a compilation error:
"""

nbCode:
  import intops/impl/inlineasm

  # These docs are compiled with -d:intopsNoInlineAsm specifically to showcase this:

  echo not compiles inlineasm.x86.carryingAdd(12'u64, 34'u64, false)

nbText:
  """

## Compilation Flags

You can control which implementations are forbidden to be picked by dispatchers using the compilation flags:

- `intopsNoIntrinsics`
- `intopsNoInlineAsm`
- `intopsNoInlineC`

For example, to avoid using Inline Assembly implementations, compile your code with `-d:intopsNoInlineAsm`:

```shell
$ nim c -d:intopsNoInlineAsm mycode.nim
```

Of course, you can combine those flags. For example, if you want to use only pure Nim implementations, pass all three forbidding flags:

```shell
$ nim c -d:intopsNoIntrinsics -d:intopsNoInlineAsm -d:intopsNoInlineC mycode.nim
```
"""

nbSave
