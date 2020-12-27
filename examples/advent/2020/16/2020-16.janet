
(def td-string ```
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12```)

(defn read-data [inp]
  (def [rulestr mystr nbstr] (string/split "\n\n" (string/trim inp)))

  # read the rules
  (def rule-names @[])
  (def rules @[])
  (loop [line :in (string/split "\n" rulestr)]
    (def m
      (peg/match '(* (<- (to ":")) ": " (<- :d+) "-" (<- :d+) " or " (<- :d+) "-" (<- :d+)) line))
    (array/push rule-names (first m))
    (array/push rules (map scan-number (drop 1 m))))

  # my ticket
  (def [title stuff] (string/split "\n" mystr))
  (def mine (map scan-number (string/split "," stuff)))

  # other tickets
  (def others
    (seq [line :in (string/split "\n" nbstr)
          :when (not (string/has-prefix? "nearby" line))]
      (map scan-number (string/split "," line))))

  [rule-names rules mine others])

(defn in-range? [[a b c d] x]
  (or (<= a x b) (<= c x d)))

(defn field-invalid-for-all-rules [rules v]
  (nil? (find |(in-range? $ v) rules)))

(defn check-tickets [rules nearby]
  (var err 0)
  (def valid-tickets @[])
  (loop [ticket :in nearby]
    (def bad-field-values
      (filter |(field-invalid-for-all-rules rules $) ticket))
    (+= err (sum bad-field-values))
    (when (empty? bad-field-values)
      (array/push valid-tickets ticket)))
  [err valid-tickets])

(defn part1 [rules nearby]
  (def [err valid] (check-tickets rules nearby))
  err)

(def [trulenames trules tmine tnearby] (read-data td-string))
#(print (part1 trules tnearby))
(assert (= 71 (part1 trules tnearby)))

(def [rulenames rules mine nearby] (read-data (slurp "input.txt")))
(print "PART1: " (part1 rules nearby))

(def td2-string ```
class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9```)

# struct mapping field name to list of possible field numbers
(defn can-be [rules tickets]
  (def r @{})
  (def tl (length (first tickets)))
  (loop [[field rng] :pairs rules]
    (def rl @[])
    (put r field rl)
    (loop [i :range [0 tl]]
      (when (all |(in-range? rng (in $ i)) tickets)
        (array/push rl i))))
  r)

(defn solve [rules ind i m]
  (if
    (= i (length rules))
       [true m]
       (let [rn (in ind i)
             rule (in rules rn)]
         (var ret [false m])
         (loop [candidate :in rule
                :when (nil? (get m candidate))]
           (def m2 (table ;(kvs m) candidate rn))
           (def [ok m3] (solve rules ind (inc i) m2))
           (when ok (do
                      (set ret [ok m3])
                      (break))))
         ret)))

(defn part2 [rulenames rules mine nearby]
  (def [_ tickets] (check-tickets rules nearby))
  (def rs (can-be rules tickets))

  # sort the "can be" rules by length of rule (to optimize search)
  (def ind (sort-by |(length (in rs $)) (range 0 (length rs))))
  (def [ok m] (solve rs ind 0 (tuple)))
  (def mm (struct ;(mapcat reverse (pairs m))))

  (product
    (seq [[i lab] :pairs rulenames
          :when (string/has-prefix? "departure" lab)]
      #(printf "using field %s %d" lab (in mine (in mm i)))
      (in mine (in mm i)))))

(def [t2rulenames t2rules t2mine t2nearby] (read-data td2-string))
(assert (= 1 (part2 t2rulenames t2rules t2mine t2nearby)))
(print "PART2: " (part2 rulenames rules mine nearby))

