# intops

`intops` is a Nim library with ready-to-use core primitives for CPU-sized integers.

The following operations are implemented:
- addition
- subtraction
- multiplication

Addition and subtraction are available in the following flavors:
- overflowing
- carrying/borrowing
- saturating

Multiplication is represented with its widening flavor.

All operations can be used during runtime and compile time. Runtime operations use C intrinsics, whereas compile-time operations are implemented in pure Nim.

Both unsigned and signed integers are supported.


## API Docs

[API Docs](https://vacp2p.github.io/nim-intops/apidocs/theindex.html)


## Usage

Operations are available in the top-level `intops` module:

```nim
import intops

let (res, carryOut) = carryingAdd(12, 34, false)
```

If you want to get specifically a runtime or a compile-time version, import `intops/pure` or `intops/native`:

```nim
import intops/native

let (res, carryOut) = carryingAdd(12, 34, false)
```

And if you want to go even deeper and call the underlying intrinsic, import `intops/intrinsics`:

```nim
import intops/intrinsics

var res: uint64

let didOverflow = overflowingAdd(12, 34, res)
```


## Running the tests

```shell
$ nimble test
```


## Building the docs

```shell
$ nimble docs
```
