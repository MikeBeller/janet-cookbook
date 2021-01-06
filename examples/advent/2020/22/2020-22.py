

def read_data(inp):
    r = ([],[])
    p = None
    for line in inp:
        if line.startswith("Player"):
            p = int(line.strip().split()[1].replace(":",""))-1
            continue
        if line == "": continue
        r[p].append(int(line.strip()))
    return r

tds = """
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
10""".strip().splitlines()

def part1(data):
    xs,ys = data[0][:], data[1][:]
    while len(xs) > 0 and len(ys) > 0:
        x = xs.pop(0)
        y = ys.pop(0)
        if x > y:
            xs.extend([x,y])
        else:
            ys.extend([y,x])
    wins = xs if len(xs) > 0 else ys
    return sum(((i+1) * v) for (i,v) in enumerate(reversed(wins)))

td = read_data(tds)
assert part1(td) == 306

data = read_data(open("input.txt").read().strip().splitlines())
print("PART1:", part1(data))

def score(xs):
    return sum((i+1)*x for (i,x) in enumerate(reversed(xs)))

def recursive_combat(lv, xs0, ys0):
    xs,ys = xs0[:], ys0[:]
    rd = 1
    seen = {}
    while len(xs) > 0 and len(ys) > 0:
        gm = (tuple(xs), tuple(ys))
        if gm in seen:
            return 0, score(xs)
        seen[gm] = True
        x = xs.pop(0)
        y = ys.pop(0)
        if x <= len(xs) and y <= len(ys):
            who,_ = recursive_combat(lv + 1, xs[:x], ys[:y])
            if who == 0:
                xs.extend([x,y])
            else:
                ys.extend([y,x])
        elif x > y:
            xs.extend([x,y])
        else:
            ys.extend([y,x])
        rd += 1

    return (0,score(xs)) if len(xs) > 0 else (1, score(ys))

def part2(data):
    xs,ys = data[0][:], data[1][:]
    who,sc = recursive_combat(0, xs, ys)
    return sc

assert part2(td) == 291
print("PART2:", part2(data))

