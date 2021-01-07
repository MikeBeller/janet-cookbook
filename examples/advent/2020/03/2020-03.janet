
(def HASH 35)  # '#' keycode

(defn read-data [inp]
  (string/split "\n" (string/trim inp)))

(def testdata ```
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#```)

(assert (let [d (read-data testdata)] (and (= 11 (length d)) (all |(= 11 (length $)) d))))

(defn checkslope [m dx dy]
  (def [h w] [(length m) (length (in m 0))])
  (var x 0)
  (var y 0)
  (var trees 0)
  (while (< y h)
    (set x (mod (+ x dx) w))
    (+= y dy)
    (when (= HASH (get-in m [y x]))
      (+= trees 1)))
  trees)

(defn part1 [inp]
  (def m (read-data inp))
  (checkslope m 3 1))

(assert (= 7 (part1 testdata)))
(print "PART1: " (part1 (slurp "input.txt")))

(defn part2 [inp]
  (def m (read-data inp))
  (product (seq [[dx dy] :in [[1 1] [3 1] [5 1] [7 1] [1 2]]]
             (checkslope m dx dy))))

(print "PART2: " (part2 (slurp "input.txt")))




