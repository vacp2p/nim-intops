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
    "-d:intopsNoIntrinsics", "-d:intopsNoInlineAsm", "-d:intopsNoInlineC",
    "-d:unittest2Static",
    "-d:unittest2Static -d:intopsNoIntrinsics -d:intopsNoInlineAsm -d:intopsNoInlineC",
  ]:
    let flags = [intopsFlagStr, archFlagStr].join(" ")

    echo fmt"# Flags: {flags}"

    selfExec fmt"r {flags} tests/tintops.nim"

task benchLatency, "Run latency benchmarks":
  let
    archFlags =
      commandLineParams().filterIt(it.startsWith("--cpu") or it.startsWith("--gcc"))
    archFlagStr = archFlags.join(" ")
    optFlagStr = """-d:danger --passC:"-march=native -O3""""
    flags = fmt"{archFlagStr} {optFlagStr}"

  echo fmt"# Flags: {flags}"

  for item in walkDir("benchmarks/latency"):
    if item.kind == pcFile and item.path.endsWith(".nim"):
      selfExec fmt"r {flags} {item.path}"

task benchThroughput, "Run throughput benchmarks":
  let
    archFlags =
      commandLineParams().filterIt(it.startsWith("--cpu") or it.startsWith("--gcc"))
    archFlagStr = archFlags.join(" ")
    optFlagStr = """-d:danger --passC:"-march=native -O3""""
    flags = fmt"{archFlagStr} {optFlagStr}"

  echo fmt"# Flags: {flags}"

  for item in walkDir("benchmarks/throughput"):
    if item.kind == pcFile and item.path.endsWith(".nim"):
      selfExec fmt"r {flags} {item.path}"

task bench, "Run benchmarks":
  exec "nimble benchLatency"
  exec "nimble benchThroughput"
