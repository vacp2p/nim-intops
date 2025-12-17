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

## API Docs

[API Index](https://vacp2p.github.io/nim-intops/apidocs/theindex.html)

## Bsic Usage

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

This command builds the nimibook and the API docs.
