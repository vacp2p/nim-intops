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

template benchImpls*(typ: typedesc, benchTmpl, opName: untyped) =
  ##[ Benchmark a given operation `opName` for type `typ` in all available implementations
  using benchmark template `benchTmpl`.
  ]##

  echo "\n=== " & astToStr(opName) & ", " & astToStr(typ) & " ==="
  benchTmpl(typ, pure.opName)
  benchTmpl(typ, intrinsics.x86.opName)
  benchTmpl(typ, intrinsics.gcc.opName)
  benchTmpl(typ, inlinec.opName)
  benchTmpl(typ, inlineasm.x86.opName)
  benchTmpl(typ, inlineasm.arm64.opName)

template benchTypesImpls*(benchTmpl, opName: untyped) =
  ##[ Benchmark a given operation `opName` for (u)int64|32 in all available implementations
  using benchmark template `benchTmpl`.
  ]##

  benchImpls(uint64, benchTmpl, opName)
  benchImpls(uint32, benchTmpl, opName)
  benchImpls(int64, benchTmpl, opName)
  benchImpls(int32, benchTmpl, opName)

template measureLatency*(
    typ: typedesc, opName: string, setupBlock, loopBlock: untyped
) =
  ##[ Universal latency measurement template. Provides random test sets of the given type,
  warms up the CPU before the benchmark, measures the latency (nanoseconds per operation),
  and prints the result.

  `{.inject.}`ed variables can be used in `setupBlock` and `loopBlock`.

  Users can `{.inject.}` variables in `setupBlock` to be later used in `loopBlock`.
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
