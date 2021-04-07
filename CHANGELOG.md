## Unreleased

## 0.5 - 2021-03-11

* Fixes
  * Support Rails 6.1 ([#79](https://github.com/unabridged/motion/pull/79))

## 0.4.4 - 2020-11-19

* Features
  * Add expanded test helpers. ([#60](https://github.com/unabridged/motion/pull/60))

* Fixes
  * Fix serializing components that use Rails' asset helpers (i.e. `image_tag`). ([#67](https://github.com/unabridged/motion/pull/67))

## 0.4.3 - 2020-09-22

* Features
  * Add support for form builders in motion state ([#47](https://github.com/unabridged/motion/pull/47))
  * Add support for Rails 5.1 ([#57](https://github.com/unabridged/motion/pull/57))

* Fixes
  * Fix memory leak and race condition allowing invocation of motion after disconnecting ([#58](https://github.com/unabridged/motion/pull/58))
  * Fix issue copying attributes using destructuring assignment from Event objects ([#57](https://github.com/unabridged/motion/pull/57))

* Removals
  * Drop support for Ruby 2.4 ([#48](https://github.com/unabridged/motion/pull/48))
  * Remove mention of removed API Event#current_target

## 0.4.2 - 2020-09-02

* Fixes
  * Upgrade of vulnerable dependencies ([#44](https://github.com/unabridged/motion/pull/44))

## 0.4.1 - 2020-08-21

* Features
  * Add compression to serialization pipeline ([#38](https://github.com/unabridged/motion/pull/38))

## 0.4.0 - 2020-07-16

* Features
  * Add Callbacks API (`bind`) ([#32](https://github.com/unabridged/motion/pull/32))
