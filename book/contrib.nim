import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
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

<span id="api"></span>
## API Conventions

1. intops follows the common Nim convention of calling things in `camelCase`.
1. intops prefers pure functions that return values to the ones that modify mutable arguments.
1. The docstrings are mandatory for the dispatchers in `intops/ops` modules because this is the library public API.
1. Operations the return a wider type that the input type are called **widening**. For example `wideningMul` is multiplication that takes two 64-bit integers and return a single 128-bit integer (althouth represented as a pair of 64-bit integers).
1. Operations that return a carry or borrow flag are called **carrying** and **borrowing**, e.g. `carryingAdd`.
1. Operations that return an overflow flag are called **overflowing**, e.g. `overflowingSub`.
1. Operations that return maximal or mininal type value when a type border is hit are called **saturating**, e.g. `saturatingAdd`.
1. Carry, borrow, and overflow flags are booleans.

<span id="tests"></span>
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
3. Run `monit run`

<span id="benchmarks"></span>
## Benchmarks

Benchmarking is crucial for a library like intops: you can't really do any reasonable dispatching improvement if you can't argue about the changes with numbers.

There are two kinds of benchmarks: latency and throughput.

*Latency benchmarks* measure how long a particular operation takes to complete. For a latency benchmark, we run the same operation against random input many times making sure the next iteration doesn't start before the previous one completes. The result is measured in nanoseconds per operation.

*Throughput benchmarks* measure how many operations of a particluar kind can be executed per unit of time. For a throughput benchmark, we spawn the same operation against random input many times back to back so that multiple instances of the same operation are executed in parallel. The results are measured in millions of operations per second.

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

<span id="docs"></span>
## Docs

The docs consist of two parts:
- the book (this is what you're reading right now)
- the API docs

The book is created using [nimibook](https://github.com/pietroppeter/nimibook). Each page is a Nim file that can hold Markdown content and Nim code. The Nim code is executed during the build and its output are included in the book.

The API docs are generated from the source code docstrings.

To build the docs locally, run:
- `nimble book` to build the book
- `nimble apidocs` to build the API docs
- `nimble docs` to build both
"""

nbSave
