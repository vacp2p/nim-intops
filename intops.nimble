# Package

version       = "0.1.0"
author        = "Constantine Molchanov"
description   = "Core arithmetic operations for CPU-sized integers."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.2.6"


task docs, "Generate API docs":
  exec "nimble doc --outdir:docs/apidocs --project --index:on src/intops.nim"
