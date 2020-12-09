
(def test-data ``
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
``)


# A few interesting peg tricks:  Note that :bag exists merely
# as a wrapper to :bg, in order to factor out the manipulation
# of the captured values from the pattern to be matched.
# Also note the "group" call in :main causes the list of bags
# to come back separate from the main color, so each result
# is a 2-tuple, where the first element is the bag color, and
# the second element is a list of (num, color) pairs.

(def pg
  (peg/compile
              ~{
                :color (sequence :w+ :s :w+)
                :bg (choice (sequence (<- "1") :s (<- :color) :s "bag")
                             (sequence (<- :d+) :s (<- :color) :s "bags"))
                :bag (cmt :bg ,(fn [a b] [(scan-number a) b]))
                :intro (sequence (<- :color) " bags contain")
                :none " no other bags."
                :baglist (sequence (any (sequence :s :bag ",")) (sequence :s :bag "."))
                :main (sequence :intro (group (choice :none :baglist)))
                }
    )
  )

(defn dbg [s] (do (print s) s))
(defn read-data [s]
  (seq [ln :in (string/split "\n" (string/trim s))]
    (peg/match pg ln)))

(def td (read-data test-data))
(assert (and (= (length td) 9)) (all |$ td))

(defn set-new [& vs]
  (apply table (seq [v :in vs] [v true])))
(defn set-add [s v]
  (put s v true))
(defn set-items [s]
  (keys s))

(defn part1 [data]
  (def g @{})
  (loop [[pcol kids] :in data]
    (loop [[n kc] :in kids]
      (put g kc (set-add (get g kc @{}) pcol))))

  (def r (set-new))
  (defn f [c]
    (each p (set-items (get g c @{}))
      (set-add r p)
      (f p)))
  (f "shiny gold")
  (set-items r))

(assert (= (length (part1 td)) 4))
(def data (read-data (slurp "input.txt")))
(print "PART1: " (length (part1 data)))

(defn nbags [g col]
  (def kids (get g col))
  (+ 1 (sum (seq [[n c] :in kids] (* n (nbags g c))))))

(defn part2 [data]
  (def g (table ;(mapcat identity data)))
  (- (nbags g "shiny gold") 1))

(assert (= (part2 td) 32))
(print "PART2: " (part2 data))

