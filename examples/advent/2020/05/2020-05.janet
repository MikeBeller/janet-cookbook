# This code is a bit interesting because I couldn't
# find a straighforward yet clean way to write it without prompt/return
# (basically Janet is otherwise missing a clean way for the loop
# macro to exit early and return a value

(defn ctoi [c] (if (or (= c 70) (= c 76)) 0 1))

(defn decode [s]
  (sum
       (seq [[i c] :pairs s]
         (* (blshift 1 (- 9 i)) (ctoi c)))))

(defn row[n] (brshift n 3))
(defn col [n] (band n 7))

(assert (let [d (decode "FBFBBFFRLR")]
          (and (= d 357) (= 44 (row d)) (= 5 (col d)))))

(def data (string/split "\n" (string/trim (slurp "input.txt"))))

(defn part1 [data]
  (reduce2 max (map decode data)))

(print "PART1: " (part1 data))

(defn part2 [data]
  (def ds (sort (map decode data)))
  (prompt :bk
          (loop [i :range [0 (length ds)]]
            (when (not= 1 (- (in ds (inc i)) (in ds i)))
              (return :bk (inc (in ds i)))))))

(print "PART2: " (part2 data))

