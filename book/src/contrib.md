# Contributor's Guide

Optimizing arithmetic operations for a variety of enviroments and consumers is a never-ending chase. There hardly will ever be a moment when intops will be 100% ready: there's always an older Nim version, and newer GCC version, or an obscure CPU vendor to target.

Because of that, contributors' help is essential for intops' development. You can help improve intops by improving the code, improving the docs, and reporting issues.

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
    │   │   ...
    │   │
    │   ├───inlineasm
    │   │       arm64.nim   <- implementation in ARM64 Assembly 
    │   │       x86.nim
    │   │       ...
    │   │
    │   └───...
    │
    └───ops                 <- operation families
            add.nim         <- addition flavors: carrying, saturating, etc.
            mul.nim
            sub.nim
            ...
```

The entrypoint is the root `intops` module. It's the library's public API and exposes all the available primitives.

Each operation family has its own submodule in `intops/ops`. E.g. `intops/ops/add` is the submodule that contains various addition flavors.

These submodules contain the dispatchers that pick the best implementation of the given operation and for the given CPU, OS, and C compiler. I.e., each operation "knows" its best implementation and "decides" which one to run.

The actual implementations are stored in submodules in `intops/impl`. For example, `intops/impl/intrinsics` contains all primitives implemented with C intrinsics.

### Composite Operations

Operations defined in `ops/composite.nim` are a little special. Their purpose is to provide conveienvce operations that glue other ones together. Think of them as syntactic sugar for calling several primitives in a row.

Dispatchers in `ops/composite.nim` to not have the typical `when` branching you see in the primitive dispatchers. Instead they are just templates that define the operations to be called and let their dispatchers decide which implementation to use.

## API Conventions

1. intops follows the common Nim convention of calling things in `camelCase`.
1. intops prefers pure functions that return values to the ones that modify mutable arguments.
1. The docstrings are mandatory for the dispatchers in `intops/ops` modules because this is the library public API.
1. Operations the return a wider type that the input type are called **widening**. For example `wideningMul` is multiplication that takes two 64-bit integers and return a single 128-bit integer (althouth represented as a pair of 64-bit integers).
1. Operations that return a carry or borrow flag are called **carrying** and **borrowing**, e.g. `carryingAdd`.
1. Operations that return an overflow flag are called **overflowing**, e.g. `overflowingSub`.
1. Operations that return maximal or mininal type value when a type border is hit are called **saturating**, e.g. `saturatingAdd`.
1. Carry, borrow, and overflow flags are booleans.

## Tests

The tests for intops are located in a single file `tests/tintops.nim`.

These are integration tests that emulate real-lfe usage of the library and check two things:

1. every dispatcher picks the proper implementation on any environment
2. the results are correct no matter the implementation

To run the tests locally, use `nimble test` command.

With this command, the tests are run:

- without compilation flags in runtime mode
- without compilation flags in compile-time mode
- with each compilation flag separately
- with all compilation flags

When executed on the CI, the tests are run against multiple OS, C compilers, and architectures:

- amd64 + Linux + gcc 13
- amd64 + Linux + gcc 14
- amd64 + Windows + clang 19
- i386 + Linux + gcc 13
- amd64 + macOS + clang 17
- arm46 + macOS + clang 17

This is hardly reproduceable locally, but you can cover at least some of the cases by passing flags to `nimble test`. For example, to emulate running the tests in a 32-bit CPU, run `nimble --cpu:i386 test`. On Windows, you also must pass the path to your GCC installation, e.g. `nimble --gcc.path:D:\mingw32\bin\ --cpu:i386 test`.
To run your tests contunously during development, use [monit](https://github.com/jiro4989/monit):

1. Install monit with `nimble install monit`.
2. Create a file called .monit.yml in the working directory:

```yaml
%YAML 1.2
%TAG !n! tag:nimyaml.org,2016:
---
!n!custom:MonitorConfig
sleep: 1
targets:
  - name: Run tests
    paths: [src, tests]
    commands:
      - nimble test
      - nimble --gcc.path:D:\mingw32\bin\ --cpu:i386 test
    extensions: [.nim]
    files: []
    exclude_extensions: []
    exclude_files: []
    once: true
```

### Writing Tests



3. Run `monit run`

## Benchmarks

Benchmarking is crucial for a library like intops: you can't really do any reasonable dispatching improvement if you can't argue about the changes with numbers.

There are two kinds of benchmarks: latency and throughput.

_Latency benchmarks_ measure how long a particular operation takes to complete. For a latency benchmark, we run the same operation against random input many times making sure the next iteration doesn't start before the previous one completes. The result is measured in nanoseconds per operation.

_Throughput benchmarks_ measure how many operations of a particluar kind can be executed per unit of time. For a throughput benchmark, we spawn the same operation against random input many times back to back so that multiple instances of the same operation are executed in parallel. The results are measured in millions of operations per second.

Benchmarks are grouped by kind and operation family, e.g. `benchmarks/latency/add.nim` contains latency benchmarks for the add operations (overflowingAdd, saturatingAdd, etc.).

To run the benchmarks locally, use `nimble bench` command:

- run latency and throughput benchmarks for all operations:

```
$ nimble bench
```

- run latency and throughput benchmarks for particular operations:

```
$ nimble bench add
$ nimble bench sub mul
```

- run latency or throughput benchmarks for all operations:

```
$ nimble bench --kind:latency
$ nimble bench --kind:throughput
```

- run particular kind of benchmarks on a particular kind of operations:

```
$ nimble bench --kind:latency add
$ nimble bench --kind:throughput sub mul
```

### Writing Benchmarks

intops ships with a ready-to-use test harness for latency and throughput benchmarks available in `benchmarks/utils.nim`:
1. `measureLatency` and `measureThroughput` templates run the actual code to be measured and produce the output (stdout and results.json).
2. `benchTypesAndImpls` template lets you measure all availalbe implementations against 32- and 64-bit types.

Here's an existing example of a `latency` benchmark for multiplication from `benchmarks/latency/mul.add` with additional comments:

```nim
# We need this for `alignLeft`.
import std/strutils

# Import all available implementations.
import intops/impl/[pure, intrinsics, inlinec, inlineasm]

# Import the test harness.
import ../utils

# In this template, we define how the benchmakr must be set up, run, and wrapped up.
# The convention is to call these templates `bench(Latency|Throughput)<OperationKind>`.
# The template accepts a type and a fully-qualified operation name.
template benchLatencyWidening*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  # Check is the given operation compiles in the current environment.
  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
  # Check that we're not falling back to an operation for a different type,
  # e.g. if we call the operation on uint32, we don't want the uint64 variant to be called.
    echo alignLeft(opName, 35), " -"
  else:
    # This is the actual meat of the benchmark.
    measureLatency(typ, opName):
      # First, we define and initialize the variables we'll need during the benchmark.
      # `inputsA` (and several more, not used here) is an array of random data provided by `measureLatency`.
      var
        currentA {.inject.} = inputsA[0]
        flush {.inject.}: typ
    do:
      # Second, we define the actual benchmarking logic.
      # In this example, since we're measuring latency, we must ensure that iterations happen one after another,
      # so the next value must depend on the previous calculation result.
      # `op` is the operation we're benchmarking.
      let (hi, lo) = op(currentA, inputsB[idx])
      currentA = hi
      flush = flush xor cast[typ](lo)
    do:
      # Finally, we do what's necessary to properly wrap up the benchmark.
      # Typically, we'll call `doNotOptimize` to force the compiler not to optimize away unused variables.
      # `doNotOptimize` is defined in `benchmarks/utils.nim` and tricks the compiler to believe the variable
      # is used in an Assembly block.
      doNotOptimize(flush)

# Wrap the template call in a `noinline` function so that the Nim compiler wouldn't produce
# one huge source code file; this would affect the benchmark results.
proc runLatencyWidening() {.noinline.} =
  # `benchTypesAndImpls` measures a given operation (e.g. `wideningMul`) with a given benchmark
  # routine (e.g. `benchLatancyWidening`) against all available implementations and types. 
  benchTypesAndImpls(benchLatencyWidening, wideningMul)

when isMainModule:
  # This is purely for the stdout reading convenience.
  echo "\n# Latency, Multiplication"

  # Call the benchmarking function.
  runLatencyWidening()
```

## Docs

The docs consist of two parts:

- the book (this is what you're reading right now)
- the API docs

The book is created using [mdBook](https://rust-lang.github.io/mdBook/).

The API docs are generated from the source code docstrings.

To build the docs locally, run:

- `nimble book` to build the book
- `nimble apidocs` to build the API docs
- `nimble docs` to build both
