# Package

version = "0.1.0"
author = "Constantine Molchanov"
description = "Core arithmetic operations for CPU-sized integers."
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 2.2.6"
requires "unittest2 ~= 0.2.5"

taskRequires "setupBook", "nimib >= 0.3.8", "nimibook >= 0.3.1"

import std/strformat

task test, "Run tests":
  for flags in [
    "-d:intopsTest -d:unittest2Static", "-d:intopsTestNative",
    "-d:intopsTestPure -d:unittest2Static",
  ]:
    echo fmt"[Flags: {flags}]"
    selfExec fmt"r {flags} tests/tintops.nim"

task setupBook, "Compiles the nimibook CLI-binary used for generating the docs":
  exec "nim c -d:release nbook.nim"

before book:
  rmDir "docs"
  exec "nimble setupBook"

task book, "Generate book":
  exec "./nbook --mm:orc --deepcopy:on update"
  exec "./nbook --mm:orc --deepcopy:on build"

before apidocs:
  rmDir "docs/apidocs"

task apidocs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on src/intops.nim"

task docs, "Generate docs":
  exec "nimble book"
  exec "nimble apidocs"
