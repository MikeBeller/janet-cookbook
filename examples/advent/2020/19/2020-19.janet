(defn to-seq [& as]
  ~(* ,;as))

(defn to-or [a b]
  ~(+ ,a ,b))

(defn parse-rules (txt)
  (def pm (peg/match
    ~{
      :line (* :num ":" :rule)
      :rule (+ :str :or :seq)
      :seq (cmt (some (* " " :num)) ,to-seq)
      :or (cmt (* :seq " |" :seq) ,to-or)
      :str (* :s+ :quote (<- :S) :quote )
      :quote `"`
      :num (cmt (<- :d+) ,keyword)
      :main (* :line (some (* :s+ :line)) -1)
      }
    txt))
  (def pg (table ;pm))
  (put pg :main '(* :0 -1))
  (table/to-struct pg))

(defn part1 (inp)
  (def [rulestr teststr] (string/split "\n\n" inp))
  (def pg (parse-rules rulestr))
  (count truthy?
         (seq [line :in (string/split "\n" teststr)]
           (peg/match pg line))))

(assert (= (part1 (slurp "test1.txt")) 2))

(print "PART1: " (part1 (slurp "input.txt")))

(defn struct-to-table [str] (table ;(mapcat identity (pairs str))))

(defn gen-all-pats []
  (seq [i :range [1 30]
        j :range [1 30]]
    ~(* (,i :42) (,j :42) (,j :31))))

(defn part2 (inp)
  (def [rulestr teststr] (string/split "\n\n" inp))
  (def pg1 (parse-rules rulestr))
  (def pgt (struct-to-table pg1))
  # the below changes didn't work so just do a hack (like we did in Julia)
  # (probably didn't work due to greediness of matches in pegs)
  #(put pgt :8 '(+ :42 (* :42 :8)))
  #(put pgt :11 '(+ (* :42 :31) (* :42 :11 :31)))
  (put pgt :0 ~(+ ,;(gen-all-pats)))
  (def pg (table/to-struct pgt))
  (count truthy?
         (seq [line :in (string/split "\n" teststr)]
           (peg/match pg line))))

(assert (= 12 (part2 (slurp "test2.txt"))))
(print "PART2: " (part2 (slurp "input.txt")))


