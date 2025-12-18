import nimibook

var book = initBookWithToc:
  entry("Welcome to intops!", "index.nim")
  entry("Quickstart", "quickstart.nim")
  section("Contributor's Guide", "contrib.nim"):
    entry("Improve dispatching", "contrib/dispatch.nim")
    entry("Add new operations", "contrib/ops.nim")
    entry("Add new implementations", "contrib/impl.nim")
  entry("Changelog", "changelog.nim")

nimibookCli(book)
