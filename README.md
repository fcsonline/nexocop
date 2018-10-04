# Nexocop

_NOTE: Nexocop is still very young, and some functionality is hardcoded (for example,
nexocop current assumes that you are diffing against `origin/master`)._

Nexocop is a thin wrapper around [rubocop](https://github.com/rubocop-hq/rubocop)
that filters out offenses that weren't introduced by the current revision
(currently only git is supported).

It is packaged to be a drop-in replacement for Rubocop.  Nexocop will
call rubocop for you, passing the same arguments to it that you invoke
nexocop with.  This means the API is the same, and for the most part
you can take your rubocop cop command and just `s/rubocop/nexocop/`.

Because nexocop calls out to rubocop to do the work, your existing rubocop
config will continue to work fine without changes.

For example, if you use rubocop like this:

```bash
bundle exec rubocop
```

Then nexocop will be used like this:


```bash
bundle exec nexocop
```

Or a fuller example:

```bash
bundle exec rubocop --format json -o rubocop.json --format html -o rubocop.html
```

will be

```bash
bundle exec nexocop --format json -o rubocop.json --format html -o rubocop.html
```

## Quick Start

Add nexocop to your `Gemfile`:

```
gem 'nexocop', '~> 0.1'
```

Profit!  (see above for usage examples)

## Things to improve

These are some ideas for improving the tool, tho it is likely that this will
break API compatibility with rubocop.  My thought is to use `--` to separate
Rubocop args and nexocop args.  If `--` is not present in the arg list, then
all the arguments will be passed to rubocop as currently happens.

1.  Add support for a -q or --quiet flag
1.  Support specifying branches
