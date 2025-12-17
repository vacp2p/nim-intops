# intops

intops is a Nim library with ready-to-use core primitives for CPU-sized integers. It is intended to be used as a foundation for other libraries that rely on manipulations with big integers, e.g. cryptography libraries.

intops offers a clean high-level API that hides the implementation details of an operation behind a dispatcher which tries to offer the best implementation for the given environment. However, you can override the dispatcher's choice and call any implementation manually.

## Installation

```shell
$ nimble install nim-intops
```

## Basic Usage

All operations are available in the top-level `intops` module:

```nim
import intops

let (res, carryOut) = carryingAdd(12'u64, 34'u64, false)
```

This code calls the `carryingAdd` dispatcher which in turn calls the best implementation available.

If you want to invoke a specific implementation, import a module from `intops/impl/` and call the function specified in it:

```nim
import intops/impl/intrinsics

let (res, carryOut) = carryingAdd(12, 34, false)
```

## Running the tests




## API Docs

[API Index](/apidocs/theindex.html)

## Basic Usage

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

To build them separately, run `nimble book` and `nimble apidocs`.
