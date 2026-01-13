# Package

version = "1.0.0"
author = "Constantine Molchanov"
description = "Core arithmetic operations for CPU-sized integers."
license = "MIT or Apache License 2.0"
srcDir = "src"

# Dependencies

requires "nim >= 2.2.6"

feature tests:
  requires "unittest2 ~= 0.2.5"

import std/[os, sequtils, strformat]

task test, "Run tests":
  let
    archFlags =
      commandLineParams().filterIt(it.startsWith("--cpu") or it.startsWith("--gcc"))
    archFlagStr = archFlags.join(" ")

  for intopsFlagStr in [
    "-d:intopsNoIntrinsics", "-d:intopsNoInlineAsm", "-d:intopsNoInlineC",
    "-d:unittest2Static",
    "-d:unittest2Static -d:intopsNoIntrinsics -d:intopsNoInlineAsm -d:intopsNoInlineC",
  ]:
    let flags = [intopsFlagStr, archFlagStr].join(" ")

    echo fmt"# Flags: {flags}"

    selfExec fmt"r {flags} tests/tintops.nim"

task book, "Generate book":
  exec "mdbook build book -d docs"

task apidocs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on --git.url:https://github.com/vacp2p/nim-intops --git.commit:develop src/intops.nim"

task docs, "Generate docs":
  exec "nimble book"
  exec "nimble apidocs"
