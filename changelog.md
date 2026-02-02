# Changelog

- [!]—backward incompatible change
- [+]—new feature
- [f]—bugfix
- [r]—refactoring
- [t]—test suite improvement
- [d]—docs improvement

## 1.0.7 (February 2, 2026)

- [f] Ops: composite: Added missing imports that prevented individual import of `intops/ops/composite` (#23).
- [d] Added into about individual imports and composite operations.

## 1.0.6 (January 19, 2026)

- [+] Ops: composite: Updated mulAcc and mulDoudleAdd2 to use the optimal implementations internally instead of pure Nim.
- [r] Impl: pure: Removed mulAcc and mulDoubleAdd2 because they no longer are guaranteed to rely on pure Nim.

## 1.0.5 (January 16, 2026)

- [+] Ops: muladd: Added wideningMulAdd for uint32.

## 1.0.4 (January 15, 2026)

- [f] Ops: division: narrowingDiv: Fix an undefined behavior bug caused by redundant normalization of an already normalized divisor.

## 1.0.3 (January 15, 2026)

- [f] Nimble: Removed unsupported requirement constraint.

## 1.0.2 (January 15, 2026)

- [+] Added support for pre-0.20.1 Nimble versions.

## 1.0.1 (January 14, 2026)

- [+] Added support for Nim 1.6.* and 2.0.*.
- [+] Ops: division: Added narrowingDiv for uint32.

## 1.0.0 (January 12, 2026)

- 🎉 initial release.
