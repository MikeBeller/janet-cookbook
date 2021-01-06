
(defn move [nxt]
  (def cur (in nxt 0))
  (def ln (dec (length nxt)))
  (def n1 (in nxt cur))
  (def n2 (in nxt n1))
  (def n3 (in nxt n2))
  (put nxt cur (in nxt n3))

  (var dc (dec cur))
  (assert (>= dc 0))
  (when (= dc 0)
    (set dc ln))
  (while (or (= dc n1) (= dc n2) (= dc n3))
    (-= dc 1)
    (when (= dc 0)
      (set dc ln)))

  (def nx (in nxt dc))
  (put nxt dc n1)
  (put nxt n3 nx)

  (put nxt 0 (in nxt cur)))

(defn part1 [cs nmoves]
  (def ln (length cs))
  (def nxt (array/new-filled (inc ln) 0))
  (var p (in cs 0))
  (put nxt 0 p)
  (loop [i :range [1 ln]]
    (put nxt p (in cs i))
    (set p (in nxt p)))
  (put nxt p (in nxt 0))

  (loop [i :range [0 nmoves]]
    (move nxt))

  (def r @[])
  (var p 1)
  (while (not= 1 (in nxt p))
    (array/push r (in nxt p))
    (set p (in nxt p)))

  r)

#(assert (deep= (part1 [3 8 9 1 2 5 4 6 7] 10) @[9 2 6 5 8 3 7 4]))
(printf "PART1: %q" (part1 [2 1 9 7 4 8 3 6 5] 100))

(defn part2 [cs nmoves]
  (def nxt (array/new-filled 1000001 0))
  (var p (in cs 0))
  (put nxt 0 p)
  (loop [i :range [1 1000001]
         :when (not= i (length cs))]
    (def nv
      (if (< i (length cs))
        (in cs i)
        i))
    (put nxt p nv)
    (set p nv))
  (put nxt p (in nxt 0))

  (loop [i :range [0 nmoves]]
    (move nxt))

  (def l1 (in nxt 1))
  (def l2 (in nxt l1))

  (* l1 l2))

#(assert (= 149245887792 (part2 [3 8 9 1 2 5 4 6 7] 10000000)))

(print "PART2: " (part2 [2 1 9 7 4 8 3 6 5] 10000000))

