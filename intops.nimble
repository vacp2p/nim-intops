# Package

version = "0.1.0"
author = "Constantine Molchanov"
description = "Core arithmetic operations for CPU-sized integers."
license = "MIT"
srcDir = "src"

# Dependencies

requires "nim >= 2.2.6"
requires "unittest2 ~= 0.2.5"

import std/[os, sequtils, strformat]

task docs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on src/intops.nim"

task test, "Run tests":
  let
    archFlags =
      commandLineParams().filterIt(it.startsWith("--cpu") or it.startsWith("--gcc"))
    archFlagStr = archFlags.join(" ")

  for intopsFlagStr in [
    "-d:intopsTest", "-d:intopsTest -d:unittest2Static", "-d:intopsTestNative",
    "-d:intopsTestPure -d:unittest2Static",
  ]:
    let flags = [intopsFlagStr, archFlagStr].join(" ")

    echo fmt"[Flags: {flags}]"

    selfExec fmt"r {flags} tests/tintops.nim"
