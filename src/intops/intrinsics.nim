type uint128* {.importc: "unsigned __int128", nodecl.} = object

func overflowingAdd*[T](
  a, b: T, res: var T
): bool {.importc: "__builtin_add_overflow", nodecl.}
  ## Checks if a + b overflows. Returns true on overflow.

func overflowingSub*[T](
  a, b: T, res: var T
): bool {.importc: "__builtin_sub_overflow", nodecl.}
  ## Checks if a - b overflows. Returns true on overflow.

