from sys import argv
from os import path
from collections import Dict

alias arrow = List[String](">", "v", "<", "^")
alias step = SIMD[DType.int16, 8](0, 1, 1, 0, 0, -1, -1, 0)


fn main() raises:
    if len(argv()) == 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = String(argv()[0]).split(".")[0] + "." + mode
        with open(filename, "rb") as f:
            var s = f.read().split("\n")
            n = len(s[0])
            process(s, n)


fn process(l: List[String], n: Int) raises:
    started = False
    pos = SIMD[DType.int16, 2](-1, -1)
    dir = -1
    visited = Dict[Int, List[Int]]()
    rlybro = List[Int]()
    visited[0] = List[Int]()
    visited[2] = List[Int]()
    visited[1] = List[Int]()
    visited[3] = List[Int]()
    rocks = List[Int]()
    rocks = List[Int]()
    loop = 0
    smpc = 0
    j = 0
    while j < n:
        if not started:
            for i in range(n):
                if l[j][i] in arrow:
                    #print(j, arrow.index(l[j][i]), sep=" ")
                    pos = SIMD[DType.int16, 2](j, i)
                    dir = arrow.index(l[j][i])
                    visited[dir] = List[Int](j * n + i)
                    rlybro = List[Int](j * n + i)
                    smpc += 1
                    started = True
                    break
        if started:
            if not int(pos[0] * n + pos[1]) in visited[dir]:
                visited[dir] += List[Int](int(pos[0] * n + pos[1]))
                #print("turaveliiiing ", len(visited))
            if not int(pos[0] * n + pos[1]) in rlybro:
                rlybro += List[Int](int(pos[0] * n + pos[1]))
            next = pos + SIMD[DType.int16, 2](step[dir * 2], step[dir * 2 + 1])
            # print("next step: ", l[int(next[0])][int(next[1])])
            if any(next < 0) or any(next >= n):
                break
            if l[int(next[0])][int(next[1])] == "#":
                dir = dir + 1 if (dir + 1) < len(arrow) else 0
                next = pos + SIMD[DType.int16, 2](
                    step[dir * 2], step[dir * 2 + 1]
                )
                print("changed dir: ", arrow[dir])
                #visited[dir] += List[Int](int(pos[0] * n + pos[1]))
            else:
              gdir = (dir + 1) if (dir + 1) < len(arrow) else 0
              gpos = pos
              gvisited = Dict[Int, List[Int]]()
              gvisited[0] = List[Int]()
              gvisited[2] = List[Int]()
              gvisited[1] = List[Int]()
              gvisited[3] = List[Int]()
              gvisited[dir] += List[Int](int(gpos[0]*n+gpos[1]))
              rock = pos + SIMD[DType.int16, 2](step[dir * 2], step[dir * 2 + 1])
              adir = (dir + 2) if (dir + 2) < len(arrow) else (dir+2) %2
              while (not (int(rock[0]*n+rock[1]) in rocks)) and (int(rock[0]*n+rock[1]) not in visited[dir]) and (int(rock[0]*n+rock[1]) not in visited[adir]):
                #print("walking", gpos)
                if any(gpos < 0) or any(gpos >=n):
                  break
                if l[int(gpos[0])][int(gpos[1])] == "#":
                  #print("Ghost found a rock")
                  gpos -= SIMD[DType.int16, 2](step[gdir * 2], step[gdir * 2 + 1])
                  gvisited[gdir] += List[Int](int(gpos[0]*n+gpos[1]))
                  gdir = (gdir + 1) if (gdir+1) < len(arrow) else 0
                  continue
                if ((int(gpos[0]*n+gpos[1]) in visited[gdir]) or (int(gpos[0]*n+gpos[1]) in gvisited[gdir])):
                  print("found", pos + SIMD[DType.int16, 2](step[dir * 2], step[dir * 2 + 1]))
                  rocks.append(int(rock[0]*n + rock[1]))
                  loop += 1
                  break
                gvisited[gdir] += List[Int](int(gpos[0]*n+gpos[1]))
                gpos += SIMD[DType.int16, 2](step[gdir * 2], step[gdir * 2 + 1])
            pos = next
            print("pos ", pos[1], pos[0])
        else:
            j += 1
    #total = 0
    """
    for item in visited.items():
        total += len(item[].value)
        print("dir ", arrow[item[].key], " len ", len(item[].value))
        for i in range(len(item[].value)):
            print(item[].value[i], end=" ")
        print()
    """
    #print("otsukare! ", total)
    print("otsukare! ", len(rlybro))
    print("cock ", loop)
    print("tits ", len(rocks))
