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
