# intops

`intops` is a Nim library with ready-to-use core primitives for CPU-sized integers.

The library aims to satisfy the following requirements:

1. Offer a complete set of arithmetic primitives on signed and unsigned integers necessary to build bignum and cryptography-focuced libraries:

- overflowing, saturating, and carrying addition
- overflowing, saturating, and borrowing subtraction
- widening and carrying multiplication
- carrying multiplication with addition

1. Support 64- and 32-bit CPUs.
1. Support Windows, Linux, and macOS.
1. Support gcc and clang.
1. Support runtime and compile time usage.
1. Offer the best implementaion for each combination of CPU, OS, C compiler, and usage time.
1. Allow the user to pick the implementation manually.
1. Future addition of new operations or implementations must not require library reorganization.

Because there are so many combinations to cover, in order to keep the code maintanable and development focused, we follow these principles during development:

1. First prefer a more general solution to a more specialized one.
1. We only test against these combinations, with runtime and compile time tests:

- amd64 + Linux + gcc 13
- amd64 + Linux + gcc 14
- amd64 + Windows + clang 19
- i386 + Linux + gcc 13
- amd64 + macOS + clang 17
- arm46 + macOS + clang 17

## Library Structure

The entrypoint is the root `intops` module. It exposes all the available primitives.

Each arithmetic operation has its own submodule in `intops/ops`. E.g. `intops/ops/add` is the submodule that contains various addition flavors. These submodules contain the logic to pick the best implementation of the given operation for the given CPU, OS, C compiler, and usage time. I.e., each operation "knows" its best implementation and "decides" which one to expose.

The actual implementations are stored in submodules in `intops/impl`. For example, `intops/impl/intrinsics` contains all primitives implemented with C intrinsics.

This structure allows the library to glow organically in evolve without breaking backward compatibility.

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
