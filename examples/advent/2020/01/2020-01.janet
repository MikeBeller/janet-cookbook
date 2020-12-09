# It turns out it's a bit tricky to break out of a double
# loop in the loop macro.  If you use :until or :while you can
# not easily capture the result.  Use break instead.

(defn part1 [data]
  (def ln (length data))
  (var ans nil)
  (loop
    [i :range [0 (dec ln)]
     j :range [(inc i) ln]
     :let [a (in data i) b (in data j)]]
    (if (= (+ a b) 2020)
      (do
        (set ans (* a b))
        (break))))
  ans)

(def td [1721 979 366 299 675 1456])
(assert (= (part1 td) 514579))

(def data (->>
            (slurp "input.txt")
            (string/trim)
            (string/split "\n")
            (map scan-number)))
(print "PART1: " (part1 data))

(defn part2 [data]
  (def ln (length data))
  (var ans nil)
  (loop
    [i :range [0 (- ln 2)]
     j :range [(+ i 1) (- ln 1)]
     k :range [(+ i 2) ln]
     :let [a (in data i) b (in data j) c (in data k)]]
    (if (= (+ a b c) 2020)
      (do
        (set ans (* a b c))
        (break))))
  ans)

(assert (= (part2 td) 241861950))
(print "PART2: " (part2 data))

