# janet-cookbook

My "cookbook" for [the Janet Language](http://janet-lang.org)

## Convert a string to a number

```janet
(scan-number "12345")  # => 12345
(scan-number "12foo")  # => nil
```

## Read a file by line

Example -- add up number of chars in each line

```janet
(with [fl (file/open "filepath")]
  (var sm 0)
  (loop [line :iterate fl]
    (+= sm (length line)))
   sm)
```

Or alternatively -- if the file is small enough that you don't mind
creating a sequence of all the lines:


```janet
(with [fl (file/open "filepath")]
  (sum
    (seq [line :iterate fl] (length line))))
```

## Default Arguments

```
(defn say-hello [a &opt b]
  (default b "World!")
  (printf "Hello %s %s" a b))
```

## Command line arguments

Available through (dyn :args).  So to get the first non-executable-name
argument of the current janet invocation, or "0" if not present.

```
(def my-arg (scan-number (get (dyn :args) 1)))
```

## Arrays

### Increment a value in an array

The ++,--,+=, X= (where X is +,-,\*,/,%) are actually macros so you can
use them on an indexed data structure like an array.

```
(def a (array/new-filled 3 0))
@[0 0 0]
(++ (a 1))
(+= (a 2 7))
(pp a)
@[0 1 7]
```

## Example Generator of Permutations

Using a simple algorithm for permutations, create a generator which generates
all permutations of an array.  We use a generator so that we do not have to
create an array of all n-factorial permutations of n items.

```
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

## Simple Multithreading

You can break a task up into a number of function calls and collect
the results with the thread/ functions in Janet core.  The idea is
to wrap the intended work function into a closure which calls the
function with the arguments, and sends the result back.  This assumes
the child will return without error.  (If not the receive will hang).

```janet
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
