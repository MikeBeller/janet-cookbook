
(def tds ```
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)

```)

(defn set/new [& items]
  (table ;(mapcat |(tuple $ true) items)))

(defn set/items [s]
  (keys s))

(defn set/in? [s i]
  (get s i false))

(defn set/union [a b]
  (merge a b))

(defn set/intersect [a b]
  (table
    ;(mapcat 
       |(tuple $ true)
       (seq [k :keys a
             :when (set/in? b k)]
         k))))

(defn read-data(inp)
  (seq [line :in (string/split "\n" (string/trim inp))]
    (peg/match
             ~{:main (* :ings " (contains " :algs ")" -1)
               :ings (cmt (* (<- :w+) (any (* " " (<- :w+)))) ,set/new)
               :algs (cmt (* (any (* (<- :w+) ", ")) (<- :w+)) ,set/new)
               }
             line)))

(defn possible-assignments [rules]
  (def all-allergens
    (reduce2 set/union (seq [[is as] :in rules] as)))
  (var can-be @{})
  (loop [alg :in (set/items all-allergens)]
    (put can-be alg
         (reduce2 set/intersect
                  (seq [[is as] :in rules
                        :when (set/in? as alg)]
                    is))))
  can-be)

(defn part1 [rules]
  (def can-be (possible-assignments rules))
  (def all-used-ings
    (reduce2 set/union (values can-be)))
  (var sm 0)
  (loop [[ings algs] :in rules]
    (+= sm
        (count
               |(not (set/in? all-used-ings $))
               (set/items ings))))
  sm)

(def test-rules (read-data tds))
(assert (= 5 (part1 test-rules)))

(def rules (read-data (slurp "input.txt")))
(print "PART1: " (part1 rules))

(defn solve [rs i m]
  (if (>= i (length rs))
    [true m]
    (let [[alg ings] (in rs i)]
      (var ret [false m])
      (loop [ing :in (set/items ings) :when (nil? (get m ing))]
        (def [ok m2] (solve rs (inc i) (struct ing alg ;(kvs m))))
        (if ok
          (do
            (set ret [ok m2])
            (break))))
      ret)))

(defn part2 [rules]
  (def can-be (possible-assignments rules))
  (def rs (pairs can-be))
  (def [ok m] (solve rs 0 {}))
  (def rm (struct ;(mapcat reverse (pairs m))))
  (string/join (seq [k :in (sort (keys rm))]
                 (in rm k)) ",")
  )

(assert (= "mxmxvkd,sqjhc,fvjkl" (part2 test-rules)))
(print "PART2: " (part2 rules))

