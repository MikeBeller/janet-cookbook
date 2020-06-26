# janet-cookbook

My "cookbook" for [the Janet Language](http://janet-lang.org)

* [Arrays and Tuples](#arrays-and-tuples)
* [Strings](#strings)
* [I/O and OS Interaction](#io-and-os-interaction)
* [Generators](#generators)
* [PEGs](#pegs)
* [Miscellaneous](#miscellaneous)

# Arrays and Tuples

## Working with arrays and tuples

Janet's indexed combinators (e.g. `map`, `filter`, `reduce`) return new
arrays, regardless of whether the collection argument passed to them was
a tuple or an array.

```clojure
janet:3:> (filter even? (range 5))
@[0 2 4]
janet:4:> (filter even? [1 2 3 4])
@[2 4]
```

If you need the result to be a tuple, you can force it with `tuple` or `tuple/slice`
as follows:

```clojure
janet:6:> (tuple ;(filter even? [1 2 3 4]))
(2 4)
janet:7:> (tuple/slice (filter even? [1 2 3 4]))
(2 4)
```

## Increment a value in an array

The augmented arithmetic assignment operators, ++,--,+=, <x>= (where X is +,-,\*,/,%)
are actually macros so you can use them on an indexed data structure like an array.

```clojure
janet:1:> (def a (array/new-filled 3 0))
@[0 0 0]
janet:2:> (++ (a 1))
1
janet:3:> (+= (a 2) 7)
7
janet:4:> a
@[0 1 7]
```

## Sorting an Array

To sort an array in place use `sort` or `sort-by`.  There are three basic ways to
sort.  The third is a little hard to find in the docs.

* By the `natural ordering` (`<` ordering) of the items in the array themselves (using `sort`)
* By the `<` ordering of a function of the items in the array (using `sort-by`)
* By any comparison function on elements a b which returns true for a < b (using `sort` with extra argument)

```clojure
# The natural ordering
janet:2:> (sort @[5 1 "7" 3 "0"])
@[1 3 5 "0" "7"]

# The ordering of a function of the items
janet:3:> (defn num [x] (if (string? x) (scan-number x) x))
<function num>
janet:4:> (sort-by num @[5 1 "7" 3 "0"])
@["0" 1 3 5 "7"]

# By any comparison function
janet:5> (sort @[5 1 "7" 3 "0"] (fn [a b] (< (num a) (num b))))
@["0" 1 3 5 "7"]
```

Note that **all of these functions modify the original array**.  Which makes them
a bit dangerous.  In general this means that code which captures the return value
from sort may be wrong.  Probably they should have been named `sort!` and `sort-by!`,
or, like python, they should have had them produce nil return values to force you
to realize that they return the same array that is passed to them. 

If you want a new array, use `sorted` and `sorted-by` instead, which return a new
array.

## Destructuring Arrays and Tuples

Note, in general destructuring works for arrays and tuples interchangeably

```clojure
# these do the same thing
(def [a b c] @[1 2 3])
(def @[a b c] [1 2 3])
```

Also when destructuring, you can destructure a longer list into a shorter one,
and vice versa.

```clojure
(def [a b] @[1 2 3])  # just sets a to 1 and b to 2
(def [a b c] [1 2])   # sets a to 1, b to 2, c to nil
```

But `match` works a bit different.  Again arrays and tuples can be used
interchangably for pattern and argument, but *a pattern that is too long
will not match*.  E.g.:

```clojure
(match [1 2] @[a b c] true false)  # will return false
```

This means that to check, for example, whether the argument is a
2-tuple or 3-tuple, you should always check 3-tuple pattern first.
Bear in mind that, a pattern of length N will actually match anything
greater than or equal to length N.

```clojure
(match [1 2] [a b c] "3-or-more-tuple" [a b] "2tuple")     # prints "2tuple"
(match [1 2 3] [a b c] "3-or-more-tuple" [a b] "2tuple")   # returns "3-or-more-tuple"
(match [1 2 3 4] [a b c] "3-or-more-tuple" [a b] "2tuple") # returns "3-or-more-tuple"
```

# Strings

## Convert a string to a number

```clojure
(scan-number "12345")  # => 12345
(scan-number "12foo")  # => nil
```

# IO and OS Interaction

N.B. -- I'm linux biased and didn't try this section on any other OS.

## Read a file by line

Example -- add up number of chars in each line

```clojure
(with [fl (file/open "filepath")]
  (var sm 0)
  (loop [line :iterate fl]
    (+= sm (length line)))
   sm)
```

Or alternatively -- if the file is small enough that you don't mind
creating a sequence of all the lines:

```clojure
(with [fl (file/open "filepath")]
  (sum
    (seq [line :iterate fl] (length line))))
```

## Command line arguments

Available through (dyn :args).  So to get the first non-executable-name
argument of the current janet invocation, or "0" if not present.

```clojure
(def my-arg (scan-number (get (dyn :args) 1)))
```

Alternatively you can create a function called main and it will get
the command line args:

```clojure
(defn main [& args]
  (print (scan-number (:in args 1))))
```

## Pretty Printing

You can allow pretty printing arbitrary width by doing

```clojure
(set-dyn :pretty-format "%j")
```

## Simple Multithreading

You can break a task up into a number of function calls and collect
the results with the thread/ functions in Janet core.  The idea is
to wrap the intended work function into a closure which calls the
function with the arguments, and sends the result back.  This assumes
the child will return without error.  (If not the receive will hang).

```clojure
(defn work [n]
  (var s 0)
  (for x 0 n
    (+= s (math/random)))
  s)

(def n 100000000)
(for i 0 4
  (thread/new (fn [parent]
                (def result (work n))
                (thread/send parent result))))
(print "RESULT " (sum (seq [i :range [0 4]] (thread/receive math/inf))))
```

# Generators

Generators are a cool feature of Janet based on threads.  They allow you to express
stream processing without having to accumulate intermediate "realizations" of the
stream.

Here are some tips and tricks that I've learned for working with them.

## The Loop Macro Makes Generators Easy to Use

Important point to understand about the below code is that nowhere in it is the
1000-element list realized.  So the code is O(1) in memory.

```clojure
# Create a list of integers
(def r (generate [i :range [1 1000]] i))
<fiber 0x55B709F9DC80>
janet:3:> # Square them
(def rsq (generate [i :generate r] (* i i)))
<fiber 0x55B709F9FF60>
janet:5:> # Add the result
(var s 0)
0
(loop [i :generate rsq] (+= s i))
nil
janet:8:> s
332833500
```

## Example Generator of Permutations

Using a simple algorithm for permutations, create a generator which generates
all permutations of an array.  We use a generator so that we do not have to
create an array of all n-factorial permutations of n items.

```clojure
(defn swap [a i j]
  (def t (a i))
  (put a i (a j))
  (put a j t))

(defn permutations [items]
  (fiber/new (fn []
               (defn perm [a k]
                 (if (= k 1)
                   (yield (tuple/slice a))
                   (do (perm a (- k 1))
                     (for i 0 (- k 1)
                       (if (even? k)
                         (swap a i (- k 1))
                         (swap a 0 (- k 1)))
                       (perm a (- k 1))))))
               (perm (array/slice items) (length items)))))

(defn tst [n]
  (var c 0)
  (loop [p :generate (permutations (range n))]
    (++ c))
  c)

(print "Number of permutations of 8 items is: " (tst 8))
```

# PEGs

PEGs are an amazing feature of Janet (and Lua via lpeg, and other languages) that
are much  more expressive than regular expressions, but like REs take some time
to learn.

## Trick to capture and print your position for debugging PEGs

Create the :p rule which you can just drop anywhere and it will
print out the current match position -- even if the pattern never
fully matches.  Here is an example where we want to match something
like an HTML tag, but we want to print out our progress (using :p) at
a number of points in the pattern:

```clojure
(def pat
  (peg/compile
    ~{:p (drop (cmt ($) ,(fn [n] (print "AT: " n) n)))
      :tag (* "<" :p (<- :w+) :p ">")
      :main :tag}))

(peg/match pat ``<foo>``)

#output:
<core/peg 0x00582798>
AT: 1
AT: 4
@["foo"]
```

# Miscellaneous

## Default Arguments

```clojure
(defn say-hello [a &opt b]
  (default b "World!")
  (printf "Hello %s %s" a b))

```

## Tables

### Create a table from a list of (k v k v)

```clojure
(def kv ["foo" 1 "bar" 2])
(table ;kv)
```

