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
  exec "nimble doc --outdir:docs/apidocs --project --index:on --git.url:https://github.com/vacp2p/nim-intops --git.devel:develop src/intops.nim"

task docs, "Generate docs":
  exec "nimble book"
  exec "nimble apidocs"
