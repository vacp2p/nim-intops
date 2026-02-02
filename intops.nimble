# Package

version = "1.0.7"
author = "Constantine Molchanov"
description = "Core arithmetic operations for CPU-sized integers."
license = "MIT or Apache License 2.0"
srcDir = "src"

# Dependencies

requires "nim >= 1.6.16", "unittest2 >= 0.2.5"

import std/[os, sequtils, strformat, parseopt, json]

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

task bench, "Run benchmarks":
  var
    modNames: seq[string]
    benchKind = "all"
    afterCmdName: bool

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      if afterCmdName:
        modNames.add(key)
      if key == "bench":
        afterCmdName = true
    of cmdLongOption, cmdShortOption:
      case key
      of "kind", "k":
        benchKind = val
    of cmdEnd:
      discard

  let
    archFlags =
      commandLineParams().filterIt(it.startsWith("--cpu") or it.startsWith("--gcc"))
    archFlagStr = archFlags.join(" ")
    optFlagStr = """-d:danger --passC:"-march=native -O3""""
    flags = fmt"{archFlagStr} {optFlagStr}"

  rmFile "results.csv"
  rmFile "results.json"

  echo fmt"# Flags: {flags}"

  if benchKind in ["all", "latency"]:
    for item in walkDir("benchmarks/latency"):
      if item.kind == pcFile and item.path.splitFile().ext == ".nim" and (
        len(modNames) > 0 and item.path.splitFile().name in modNames or
        len(modNames) == 0
      ):
        selfExec fmt"r {flags} {item.path}"

  if benchKind in ["all", "throughput"]:
    for item in walkDir("benchmarks/throughput"):
      if item.kind == pcFile and item.path.splitFile().ext == ".nim" and (
        len(modNames) > 0 and item.path.splitFile().name in modNames or
        len(modNames) == 0
      ):
        selfExec fmt"r {flags} {item.path}"

task bencher, "Generate results.json in Bencher Measurement Format (BMF)":
  var entries = newJObject()

  for line in readFile("results.csv").splitLines:
    if len(line) == 0:
      continue

    let
      components = line.split(",")
      entryKind = components[0]
      entryName = components[1] & "_" & components[2]
      entryVal = parseFloat(components[3])

    if entryName notin entries:
      entries.add(entryName, %*{})

    entries[entryName].add(entryKind, %*{"value": entryVal})

  writeFile("results.json", pretty entries)

  echo "Benchmark results saved to results.json."

task book, "Generate book":
  exec "mdbook build book -d docs"

task apidocs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on --git.url:https://github.com/vacp2p/nim-intops --git.commit:develop src/intops.nim"

task docs, "Generate docs":
  exec "nimble book"
  exec "nimble apidocs"
