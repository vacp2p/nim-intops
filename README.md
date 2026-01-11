# intops

intops is a Nim library with ready-to-use core primitives for CPU-sized integers. It is intended to be used as a foundation for other libraries that rely on manipulations with big integers, e.g. cryptography libraries.

intops offers a clean high-level API that hides the implementation details of an operation behind a dispatcher which tries to offer the best implementation for the given environment. However, you can override the dispatcher's choice and call any implementation manually.

- [Quickstart →](https://vacp2p.github.io/nim-intops/quickstart.html)
- [API Index →](https://vacp2p.github.io/nim-intops/apidocs/theindex.html)
- [Issues →](https://github.com/vacp2p/nim-intops/issues)
- [Contributor's Guide →](https://vacp2p.github.io/nim-intops/contrib.html)

intops aims to satisfy the following requirements:

1. Offer a complete set of arithmetic primitives on signed and unsigned integers necessary to build bignum and cryptography-focuced libraries: addition, subtraction, multiplication, division, and composite operations.
1. Support 64- and 32-bit integers.
1. Support 64- and 32-bit CPUs.
1. Support Windows, Linux, and macOS.
1. Support GCC-compatible and MSVC compilers.
1. Support runtime and compile time usage.
1. Offer the best implementaion for each combination of CPU, OS, C compiler, and usage time.
1. Allow the user to pick the implementation manually.

## License

Licensed and distributed under either of

- MIT license: [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT

or

- Apache License, Version 2.0, ([LICENSE-APACHEv2](LICENSE-APACHEv2) or http://www.apache.org/licenses/LICENSE-2.0)

at your option. This file may not be copied, modified, or distributed except according to those terms.
