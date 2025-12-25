func doNotOptimize*[T](x: var T) {.inline.} =
  ## Force the compiler to avoid optimizing away a variable.

  when defined(gcc) or defined(clang):
    {.emit: """asm volatile("" : "+g"(`x`) : : "memory");""".}
  else:
    var volatileSink {.volatile.}: T = x
