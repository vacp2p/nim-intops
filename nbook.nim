import nimibook

var book = initBookWithToc:
  entry("Welcome to intops!", "index.nim")
  entry("Quickstart", "quickstart.nim")
  section("Contributor's Guide", "contrib.nim"):
    entry("Operations", "contrib/ops.nim")
    entry("Implementations", "contrib/impl.nim")
  entry("Changelog", "changelog.nim")

nimibookCli(book)
