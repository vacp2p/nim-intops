import std/[random, monotimes, times, strutils]

const
  iterations* = 100_000_000
  bufSize* = 1024

func doNotOptimize*[T](x: var T) {.inline.} =
  ## Force the compiler to avoid optimizing away a variable.

  when defined(gcc) or defined(clang):
    {.emit: """asm volatile("" : "+g"(`x`) : : "memory");""".}
  else:
    var volatileSink {.volatile.}: T = x

template measureLatency*(typ: typedesc, opName: string, setupBlock, loopBlock: untyped) =
  ##[ Universal latency measurement template. Provides random test sets of the given type,
  warms up the CPU before the benchmark, measures the laetncy (nanoseconds per operation),
  and prints the result.

  Injected variables can be used in `setupBlock` and `loopBlock`.

  The user can define new injected variables in `setupBlock` that can then be used in `loopBlock`.
  ]##

  block:
    var
      randGen = initRand(123)
      flush {.inject.}: typ
      inputsA {.inject.}: array[bufSize, typ]
      inputsB {.inject.}: array[bufSize, typ]

    for i in 0 ..< bufSize:
      inputsA[i] = typ(randGen.next())
      inputsB[i] = typ(randGen.next())

    setupBlock

    for i in 0 ..< 1000:
      let idx {.inject.} = i and (bufSize - 1)
      loopBlock

    let timeStart = getMonoTime()

    for i in 0 ..< iterations:
      let idx {.inject.} = i and (bufSize - 1)
      loopBlock

    let timeFinish = getMonoTime()

    doNotOptimize(flush)

    let
      timeDelta = (timeFinish - timeStart).inNanoseconds
      nanosecsPerOp = float64(timeDelta) / float64(iterations)

    echo alignLeft(opName, 35), " ", formatFloat(nanosecsPerOp, ffDecimal, 3)
