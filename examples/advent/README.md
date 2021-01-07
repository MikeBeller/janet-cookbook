# Advent of Code in Janet

Example solutions in Janet to some Advent of Code problems.

    https://adventofcode.com/

Some also have python implementations for comparison purposes.

A few things I learned:

* It reinforced to me that Janet is often faster than Python. See
  for example 2020/23 -- it's basically just array manipulation, and
  Janet (1.13--compiled with lto) is around twice as fast as Python
  3.8.
* PEGs are great!  Much more powerful than regexes.  For an interesting
  example of this see 2020/19.  There I use a PEG to parse the rules
  portion of the input.  That PEG generates another PEG which is used
  to test the remaining input against the rules.
* If that's a bit over the top, see 2020/16 for a simpler use of PEGs.

