# Package

version = "0.1.0"
author = "Constantine Molchanov"
description = "Core arithmetic operations for CPU-sized integers."
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 2.2.6"
requires "unittest2 ~= 0.2.5"

import std/strformat

task docs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on src/intops.nim"

task test, "Run tests":
  for flags in [
    "-d:intopsTest -d:unittest2ListTests", "-d:intopsTest -d:unittest2Static",
    "-d:intopsTestNative -d:unittest2ListTests", "-d:intopsTestPure -d:unittest2Static",
  ]:
    echo fmt"[Flags: {flags}]"
    selfExec fmt"r {flags} tests/tintops.nim"
