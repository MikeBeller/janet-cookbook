
(defn read-data [inp]
  (def xs @[])
  (def ys @[])
  (var cur xs)
  (loop [line :in (string/split "\n" (string/trim inp))]
    (cond
      (string/has-prefix? "Player" line)
        (when (string/has-suffix? "2:" line) (set cur ys))
      (= line "")
        nil
      (array/push cur (scan-number line))))
  [xs ys])

(def TDS `
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10`)

(defn score [xs]
  (sum
       (seq [[i v] :pairs (reverse xs)]
         (* v (inc i)))))

(defn part1 [inp]
  (def [xs ys] (read-data inp))
  (while (and (not (empty? xs)) (not (empty? ys)))
    (def [x y] [(in xs 0) (in ys 0)])
    (array/remove xs 0)
    (array/remove ys 0)
    (if (> x y)
      (array/concat xs x y)
      (array/concat ys y x))
    )
  (def wins
    (if (not (empty? xs)) xs ys))
  (score wins))

(assert (= 306 (part1 TDS)))
(print "PART1: " (part1 (slurp "input.txt")))

# always send this a fresh xs/ys as they get destroyed
(defn recursive-combat [lv xs ys]
  (def seen @{})
  (var ret nil)
  (while (and (not (empty? xs)) (not (empty? ys)))
    (def gm [(tuple/slice xs) (tuple/slice ys)])
    (when (get seen gm)
      (set ret [0 (score xs)])
      (break))
    (put seen gm true)
    (def [x y] [(in xs 0) (in ys 0)])
    (array/remove xs 0)
    (array/remove ys 0)
    (cond
      (and (<= x (length xs)) (<= y (length ys)))
        (do
          (def [who _] 
            (recursive-combat (inc lv)
                              (array/slice xs 0 x)
                              (array/slice ys 0 y)))
          (if (= who 0)
            (array/concat xs x y)
            (array/concat ys y x)))
      (> x y)
        (array/concat xs x y)
      (array/concat ys y x)))
  (if ret
    ret
    (if (not (empty? xs))
      [0 (score xs)]
      [1 (score ys)])))

(defn part2 [inp]
  (def [xs ys] (read-data inp))
  (def [who sc] (recursive-combat 0 (array/slice xs) (array/slice ys)))
  sc)

(assert (= 291 (part2 TDS)))

(print "PART2: " (part2 (slurp "input.txt")))


