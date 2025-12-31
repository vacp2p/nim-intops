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

template measureLatency*(
    typ: typedesc, opName: string, setupBlock, loopBlock, teardownBlock: untyped
) =
  ##[ Universal latency measurement template.

  Provides random test sets of the given type,
  warms up the CPU before the benchmark, measures the latency (nanoseconds per operation),
  and prints the result.

  `{.inject.}`ed variables can be used in `setupBlock`,`loopBlock`,
  and `teardownBlock`.

  Users can `{.inject.}` variables in `setupBlock` to be later used in `loopBlock`
  and `teardownBlock`.
  ]##

  block:
    var
      randGen = initRand(123)
      inputsA {.inject.}: array[bufSize, typ]
      inputsB {.inject.}: array[bufSize, typ]
      inputsC {.inject.}: array[bufSize, typ]
      inputsD {.inject.}: array[bufSize, typ]

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

    teardownBlock

    let
      timeDelta = (timeFinish - timeStart).inNanoseconds
      nanosecsPerOp = float64(timeDelta) / float64(iterations)

    echo alignLeft(opName, 35), " ", formatFloat(nanosecsPerOp, ffDecimal, 3), " ns/op"

template measureThroughput*(
    typ: typedesc, opName: string, setupBlock, loopBlock, teardownBlock: untyped
) =
  ##[ Universal throughput measurement template.

  Provides random test sets of the given type,
  warms up the CPU before the benchmark, measures the throughput
  (millions of operations per second), and prints the result.

  `{.inject.}`ed variables can be used in `setupBlock`,`loopBlock`,
  and `teardownBlock`.

  Users can `{.inject.}` variables in `setupBlock` to be later used in `loopBlock`
  and `teardownBlock`.
  ]##

  block:
    var
      randGen = initRand(123)
      inputsA {.inject.}: array[bufSize, typ]
      inputsB {.inject.}: array[bufSize, typ]
      inputsC {.inject.}: array[bufSize, typ]
      inputsD {.inject.}: array[bufSize, typ]
      boolInputs {.inject.}: array[bufSize, bool]

    for i in 0 ..< bufSize:
      inputsA[i] = typ(randGen.next())
      inputsB[i] = typ(randGen.next())
      boolInputs[i] = bool(randGen.next() mod 2)

    setupBlock

    for i in 0 ..< 1000:
      let idx {.inject.} = i and (bufSize - 1)
      loopBlock

    let timeStart = getMonoTime()
    for i in 0 ..< iterations:
      let idx {.inject.} = i and (bufSize - 1)
      loopBlock
    let timeFinish = getMonoTime()

    teardownBlock

    let
      totalNs = float64((timeFinish - timeStart).inNanoseconds)
      seconds = totalNs / 1_000_000_000.0
      opsPerSec = float64(iterations) / seconds
      mops = opsPerSec / 1_000_000.0

    echo alignLeft(opName, 35), " ", mops.formatFloat(ffDecimal, 3), " Mops/s"

template benchImpls*(typ: typedesc, benchTempl, opName: untyped) =
  ##[ Benchmark a given operation `opName` for type `typ` in all available implementations
  using benchmark template `benchTempl`.
  ]##

  echo "\n## " & astToStr(opName) & ", " & astToStr(typ)

  benchTempl(typ, pure.opName)
  benchTempl(typ, intrinsics.x86.opName)
  benchTempl(typ, intrinsics.gcc.opName)
  benchTempl(typ, inlinec.opName)
  benchTempl(typ, inlineasm.x86.opName)
  benchTempl(typ, inlineasm.arm64.opName)

template benchTypesAndImpls*(benchTempl, opName: untyped) =
  ##[ Benchmark a given operation `opName` for (u)int64|32 in all available implementations
  using benchmark template `benchTempl`.
  ]##

  benchImpls(uint64, benchTempl, opName)
  benchImpls(uint32, benchTempl, opName)
  benchImpls(int64, benchTempl, opName)
  benchImpls(int32, benchTempl, opName)

template benchLatencyOverflowing*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        currentA {.inject.} = inputsA[0]
        resFlush {.inject.}: typ
        ovfFlush {.inject.}: bool
    do:
      let (res, didOverflow) = op(currentA, inputsB[idx])
      ovfFlush = ovfFlush xor didOverflow
      currentA = res xor typ(ovfFlush)
      resFlush = currentA
    do:
      doNotOptimize(resFlush)
      doNotOptimize(ovfFlush)

template benchLatencySaturating*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        flush {.inject.}: typ
        currentA {.inject.} = inputsA[0]
    do:
      currentA = op(currentA, inputsB[idx])
      flush = currentA
    do:
      doNotOptimize(flush)

template benchLatencyCarrying*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), false):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), false)[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureLatency(typ, opName):
      var
        flush {.inject.}: typ
        carryIn {.inject.}: bool
    do:
      let (res, carryOut) = op(inputsA[idx], inputsB[idx], carryIn)
      flush = res
      carryIn = carryOut
    do:
      doNotOptimize(flush)

template benchThroughputOverflowing*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var flush {.inject.}: typ
    do:
      let (res, didOverflow) = op(inputsA[idx], inputsB[idx])
      flush = flush xor res xor cast[typ](didOverflow)
    do:
      doNotOptimize(flush)

template benchThroughputSaturating*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ)):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ))) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var flush {.inject.}: typ
    do:
      let res = op(inputsA[idx], inputsB[idx])
      flush = flush xor res
    do:
      doNotOptimize(flush)

template benchThroughputCarrying*(typ: typedesc, op: untyped) =
  let opName = astToStr(op)

  when not compiles op(default(typ), default(typ), false):
    echo alignLeft(opName, 35), " -"
  elif typeof(op(default(typ), default(typ), false)[0]) isnot typ:
    echo alignLeft(opName, 35), " -"
  else:
    measureThroughput(typ, opName):
      var flush {.inject.}: typ
    do:
      let (res, _) = op(inputsA[idx], inputsB[idx], boolInputs[idx])
      flush = flush xor res
    do:
      doNotOptimize(flush)
