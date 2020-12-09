
(defn read-data [inp]
  (def lines (string/split "\n" (string/trim inp)))
  (def pg
    (peg/compile
                ~{
                  :num (cmt (<- :d+) ,scan-number)
                  :chr (cmt (<- :a) ,|(in $ 0))
                  :main (* :num "-" :num :s+ :chr ":" :s+ (<- :a+))}))
  (seq [line :in lines]
    (peg/match pg line)))

(def test-data ``
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
``)

(def td (read-data test-data))

(defn part1 (data)
  (sum
       (seq [[mn mx ch pw] :in data
             :let [cc (count |(= $ ch) pw)]]
         (if (and (>= cc mn) (<= cc mx)) 1 0))))

(assert (= (part1 td) 2))
(def data (read-data (slurp "input.txt")))
(print "PART1: " (part1 data))

(defn part2 (data)
  (sum
       (seq [[mn mx ch pw] :in data
             :let [cc (count |(= $ ch) [(in pw (dec mn)) (in pw (dec mx))])]]
         (if (= cc 1) 1 0))))

(assert (= (part2 td) 1))
(print "PART2: " (part2 data))
