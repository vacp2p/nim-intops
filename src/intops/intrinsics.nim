func builtin_add_overflow*[T](a, b: T, res: var T): bool
  {.importc: "__builtin_add_overflow", nodecl.}
  ## Checks if a + b overflows. Returns true on overflow.

func builtin_sub_overflow*[T](a, b: T, res: var T): bool
  {.importc: "__builtin_sub_overflow", nodecl.}
  ## Checks if a - b overflows. Returns true on overflow.
