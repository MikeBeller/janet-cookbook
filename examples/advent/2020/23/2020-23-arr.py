
def move(nxt):
    cur = nxt[0]
    ln = len(nxt) - 1

    # pick up 3 and "remove" them
    n1 = nxt[cur]
    n2 = nxt[n1]
    n3 = nxt[n2]
    nxt[cur] = nxt[n3]

    # find next label down numerically as the destination cup
    # (as long as destination cup is not in the removed nodes)
    dc = cur - 1
    if dc == 0: dc = ln
    while dc == n1 or dc == n2 or dc == n3:
        dc -= 1
        if dc == 0: dc = ln

    # put the removed cups clockwise of the destination cup
    nx = nxt[dc]
    nxt[dc] = n1
    nxt[n3] = nx

    # new current is one node clockwise of the current
    nxt[0] = nxt[cur]

def part1(cs, nmoves):
    ln = len(cs)
    nxt = [0] * (ln+1)
    p = nxt[0] = cs[0]
    for i in range(1,len(cs)):
        nxt[p] = cs[i]
        p = nxt[p]
    nxt[p] = nxt[0]
    for i in range(nmoves):
        move(nxt)
    r = []
    p = 1
    while nxt[p] != 1:
        r.append(nxt[p])
        p = nxt[p]
    return r

#assert part1([3, 8, 9, 1, 2, 5, 4, 6, 7], 10) == [9, 2, 6, 5, 8, 3, 7, 4]
print("PART1:", part1([2, 1, 9, 7, 4, 8, 3, 6, 5], 100))


def part2(cs, nmoves):
    nxt = [0] * 1000001
    #nxt = {}               # test a dict instead of a python list
    #import array           # test an array.array instead
    #nxt = array.array('I', [0]*1000001)
    #import numpy as np     # test a numpy array (horrible performance)
    #nxt = np.zeros(1000001,np.int64)
    nxt[0] = cs[0]
    p = nxt[0]
    for i in range(1,1000001):
        if i < len(cs):
            nxt[p] = cs[i]
        elif i == 9:
            continue
        else:
            nxt[p] = i
        p = nxt[p]
    nxt[p] = nxt[0]

    for i in range(nmoves):
        move(nxt)

    l1 = nxt[1]
    l2 = nxt[l1]

    return l1 * l2

#assert part2([3, 8, 9, 1, 2, 5, 4, 6, 7], 10000000) == 149245887792
#print("PART2:", part2([2, 1, 9, 7, 4, 8, 3, 6, 5], 10000000))

if __name__ == '__main__':
    import timeit
    print("TIME:", timeit.timeit('print("PART2:", part2([2, 1, 9, 7, 4, 8, 3, 6, 5], 10000000))', globals=locals(), number=1))
