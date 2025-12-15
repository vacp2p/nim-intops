import nimibook

var book = initBookWithToc:
  entry("Welcome to intops!", "index.nim")
  entry("Overview", "overview.md")
  # section("Contributor's Guide", "contrib.md"):
  #   entry("Add new operations", "contrib/ops.md")
  #   entry("Add new implementations", "contrib/impl.md")
  #   entry("Improve dispatching", "contrib/dispatch.md")
  entry("Changelog", "changelog.nim")

nimibookCli(book)
