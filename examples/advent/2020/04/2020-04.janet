
(defn read-data [inp]
  (seq [line :in (string/split "\n\n" (string/trim inp))]
    (def prs (string/split " " (string/replace-all "\n" " " line)))
    (struct ;(mapcat |(string/split ":" $) prs))))

(def test-data `
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in`)

(defn has-all-fields [reqd pport]
  (all |(get pport $) reqd))

(defn part1 [inp]
  (def pports (read-data inp))
  (def reqd ["byr" "iyr" "eyr" "hgt" "hcl" "ecl" "pid"])
  (count (partial has-all-fields reqd) pports))

(assert (= 2 (part1 test-data)))

(print "PART1: " (part1 (slurp "input.txt")))

(defn checkyr [mn mx s]
  (def m (peg/match '(<- (* :d :d :d :d -1)) s))
  (if (nil? m) nil
    (let [n (scan-number (in m 0))]
      (and (>= n mn) (<= n mx)))))

(defn checkhgt [hgt]
  (def m (peg/match '(* (<- :d+) (<- (+ "in" "cm"))) hgt))
  (if (nil? m) nil
    (let [n (scan-number (in m 0))]
      (if (= (in m 1) "cm")
        (and (>= n 150) (<= n 193))
        (and (>= n 59) (<= n 76))))))

(defn checkhcl [s] (peg/match '(* "#" (6 (range "09" "af")) -1) s))
(defn checkecl [s] (peg/match '(+ "amb" "blu" "brn" "gry" "grn" "hzl" "oth") s))
(defn checkpid [s] (peg/match '(* (9 :d) -1) s))
(defn checkcid [s] true)

(def validate {
               "byr" (partial checkyr 1920 2002)
               "iyr" (partial checkyr 2010 2020)
               "eyr" (partial checkyr 2020 2030)
               "hgt" checkhgt
               "hcl" checkhcl
               "ecl" checkecl
               "pid" checkpid
               "cid" checkcid })

(defn valid [p]
  (every? 
    (seq [f :keys validate]
      ((get validate f) (get p f "")))))

(def tests `
byr valid: 2002
byr invalid: 2003
hgt valid: 60in
hgt valid: 190cm
hgt invalid: 190in
hgt invalid: 190
hcl valid: #123abc
hcl invalid: #123abz
hcl invalid: 123abc
ecl valid: brn
ecl invalid: wat
pid valid: 000000001
pid invalid: 0123456789`)

(loop [line :in (string/split "\n" (string/trim tests))]
  (def [f res v] (string/split " " line))
  (def val ((in validate f) v))
  (when (or (and (= res "valid:") (not val)) (and (= res "invalid:") val))
    (print "test: " line " failed")
    (assert false))
  )

(def invalid-pports `
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007`)

(assert (all |(not (valid $)) (read-data invalid-pports)))


(def valid-pports `
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719`)

(assert (all valid (read-data valid-pports)))

(defn part2 [inp]
  (count valid (read-data inp)))

(print "PART2: " (part2 (slurp "input.txt")))

