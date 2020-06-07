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

## Example Generator of Permutations

Using a simple algorithm for permutations, create a generator which generates
all permutations of an array.  (This can be important because permutations might
otherwise generate a very long, unnecessary array.)

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
