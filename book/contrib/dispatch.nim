import nimib, nimibook

nbInit(theme = useNimibook)

nbText:
  """
# Improving Dispatching

When you invoke a primitive, it decides which of its implementation to call with the given environment. This logic is described in templates at `intops/ops/{op}.nim`. We call these template **dispatchers**.

To improve this logic, locate the operation and the template you want to modify and make your edits.

To define logic branches, use the global constants defined in `intops/consts.nim`. If necessary, define new constants.

TODO
"""

nbSave
