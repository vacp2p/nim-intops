import std/[random, monotimes, times, strformat]

import intops/impl/[pure, intrinsics, inlinec, inlineasm]

import benchutils

const
  iterations = 100_000_000
  bufSize = 1024

template benchmarkLatencyCarryingAdd(typ: typedesc, opName: untyped) =
  block:
    var
      randGen = initRand()
      inputsA = newSeq[typ](bufSize)
      inputsB = newSeq[typ](bufSize)
      sink: typ
      carryIn: bool

    for i in 0 ..< bufSize:
      inputsA[i] = typ(randGen.next())
      inputsB[i] = typ(randGen.next())

    for i in 0 ..< 1000:
      let
        idx = i and (bufSize - 1)
        (res, _) = opName(inputsA[idx], inputsB[idx], sink > 0)

      sink = res

    let timeStart = getMonoTime()
    for i in 0 ..< iterations:
      let
        idx = i and (bufSize - 1)
        (res, carryOut) = opName(inputsA[idx], inputsB[idx], carryIn)

      sink = res
      carryIn = carryOut

    let timeFinish = getMonoTime()

    doNotOptimize(sink)

    let
      timeDelta = float64((timeFinish - timeStart).inNanoseconds)
      nanoSecsPerOp {.inject.} = timeDelta / float64(iterations)
      opNameStr {.inject.} = astToStr(opName)

    echo fmt"{opNameStr:<30} {nanoSecsPerOp}"

template benchmarkCarryingAdd(typ: typedesc, opName: untyped) =
  block:
    when compiles opName(typ(0), typ(0), false):
      benchmarkLatencyCarryingAdd(typ, opName)
    else:
      let opNameStr {.inject.} = astToStr(opName)
      echo &"{opNameStr:<30} -"

echo "=== Carrying Add, uint64 ==="
benchmarkCarryingAdd(uint64, pure.carryingAdd)
benchmarkCarryingAdd(uint64, intrinsics.x86.carryingAdd)
benchmarkCarryingAdd(uint64, intrinsics.gcc.carryingAdd)
benchmarkCarryingAdd(uint64, inlinec.carryingAdd)
benchmarkCarryingAdd(uint64, inlineasm.x86.carryingAdd)
benchmarkCarryingAdd(uint64, inlineasm.arm64.carryingAdd)

echo "=== Carrying Add, uint32 ==="
benchmarkCarryingAdd(uint32, pure.carryingAdd)
benchmarkCarryingAdd(uint32, intrinsics.x86.carryingAdd)
benchmarkCarryingAdd(uint32, intrinsics.gcc.carryingAdd)
benchmarkCarryingAdd(uint32, inlinec.carryingAdd)
benchmarkCarryingAdd(uint32, inlineasm.x86.carryingAdd)
benchmarkCarryingAdd(uint32, inlineasm.arm64.carryingAdd)
