#!/usr/bin/env mojo
# fg : \033[38;2;<r>;<g>;<b>m
# bg : \033[48;2;<r>;<g>;<b>m
import benchmark
from sys import argv
from os import path
from memory import memset_zero
from collections import Dict

alias numbers = List[Int](ord("0"), ord("1"),ord("2"),ord("3"),ord("4"),ord("5"),ord("6"),ord("7"),ord("8"),ord("9"))
alias AoCResult = UnsafePointer[Scalar[DType.uint64]]
alias AoCPart = fn (List[String], AoCResult) raises -> None
alias Trail = SIMD[DType.int16,8]
alias Step = SIMD[DType.int16, 2]
alias Point = SIMD[DType.int16, 2]
alias steps = List[Step](Step(1,0),Step(0,1),Step(-1,0),Step(0,-1))
alias dir = List[Int](ord("v"), ord(">"),ord("^"),ord("<"))
alias mu = "μs"


fn p1(l: List[String], r: AoCResult) raises -> None:
    n = len(l)
    different_paths = 0
    result = 0
    trails = List[Trail]()
    reached = Dict[Int,List[Int]]()
    j = 0
    run_trails = False
    while j < n or run_trails:
      for i in range(n):
        if j >= n:
          break
        v = ord(l[j][i])
        if v == numbers[0]:
          p = Point(j,i)
          for z in range(len(steps)):
            s = Point(p[0]+steps[z][0], p[1]+steps[z][1])
            if all(s < n) and all(s >=0):
              if (ord(l[int(s[0])][int(s[1])]) -ord(l[int(p[0])][int(p[1])])) == 1:
                trails.append( Trail(dir[z], ord(l[j][i]),j, i,j*n +i ))
                if not j*n+i in reached:
                  reached[j*n+i] = List[Int]()
                run_trails = True
      j += 1
      if run_trails:
        for k in range(len(trails)):
          if trails[k][1] == numbers[9]:
            different_paths+= 1
            goal = int(trails[k][2]*n + trails[k][3])
            if not goal  in reached[int(trails[k][4])]:
              reached[int(trails[k][4])].append(goal)
            _ = trails.pop(k)
            break
          plausible = List[Trail]()
          for z in range(len(steps)):
            s = Point(trails[k][2]+steps[z][0], trails[k][3]+steps[z][1])
            if all(s < n) and all(s >=0):
              if (ord(l[int(s[0])][int(s[1])]) - trails[k][1]) == 1:
                plausible.append(Trail(dir[z], ord(l[int(s[0])][int(s[1])]), s[0], s[1], trails[k][4]))
          if len(plausible) == 0:
            _ = trails.pop(k)
            break
          else:
            trails[k] = plausible.pop(0)
            if trails[k][1] == numbers[9]:
              different_paths+= 1
              goal = int(trails[k][2]*n + trails[k][3])
              if not goal  in reached[int(trails[k][4])]:
                reached[int(trails[k][4])].append(goal)
              _ = trails.pop(k)
            for i in range(len(plausible)):
              trails.append(plausible[i])
            break
        if len(trails) == 0 and j >= n:
          run_trails = False
    for k in reached:
      result += len(reached[k[]])
    r.store[width=1](result)


fn p2(l: List[String], r: AoCResult) raises -> None:
    n = len(l)
    different_paths = 0
    result = 0
    trails = List[Trail]()
    reached = Dict[Int,List[Int]]()
    j = 0
    run_trails = False
    while j < n or run_trails:
      for i in range(n):
        if j >= n:
          break
        v = ord(l[j][i])
        if v == numbers[0]:
          p = Point(j,i)
          for z in range(len(steps)):
            s = Point(p[0]+steps[z][0], p[1]+steps[z][1])
            if all(s < n) and all(s >=0):
              if (ord(l[int(s[0])][int(s[1])]) -ord(l[int(p[0])][int(p[1])])) == 1:
                trails.append( Trail(dir[z], ord(l[int(s[0])][int(s[1])]),s[0], s[1],j*n +i ))
                if not j*n+i in reached:
                  reached[j*n+i] = List[Int]()
                run_trails = True
      j += 1
      if run_trails:
        for k in range(len(trails)):
          if trails[k][1] == numbers[9]:
            different_paths+= 1
            goal = int(trails[k][2]*n + trails[k][3])
            if not goal  in reached[int(trails[k][4])]:
              reached[int(trails[k][4])].append(goal)
            _ = trails.pop(k)
            break
          plausible = List[Trail]()
          for z in range(len(steps)):
            s = Point(trails[k][2]+steps[z][0], trails[k][3]+steps[z][1])
            if all(s < n) and all(s >=0):
              if (ord(l[int(s[0])][int(s[1])]) - trails[k][1]) == 1:
                plausible.append(Trail(dir[z], ord(l[int(s[0])][int(s[1])]), s[0], s[1], trails[k][4]))
          if len(plausible) == 0:
            _ = trails.pop(k)
            break
          else:
            trails[k] = plausible.pop(0)
            for i in range(len(plausible)):
              trails.append(plausible[i])
            break
        if len(trails) == 0 and j >= n:
          run_trails = False
    for k in reached:
      result += len(reached[k[]])
    r.store[width=1](different_paths)


fn main() raises:
    if len(argv()) >= 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = String(argv()[0]).replace("mojo", mode)
        var s = List[String]()
        var result = AoCResult.alloc(1)
        memset_zero(result.address, 1)
        var result2 = AoCResult.alloc(1)
        memset_zero(result2.address, 1)
        with open(filename, "rb") as f:
            var input = f.read().splitlines()
            s = input
        if len(argv()) == 3:
          print("p1 took:", bench[p1](s, result))
          print("p2 took:", bench[p2](s, result2))
        else:
          p1(s, result)
          print("result p1:", result.load[width=1]())
          p2(s, result2)
          print("result p2:", result2.load[width=1]())


fn bench[f: AoCPart](s: List[String], r: AoCResult) raises -> String:
    @parameter
    fn test_fn():
        try:
            _ = f(s, r)
        except e:
            print("IAAAA ONIICHAN")
            print(e)
        pass

    m = benchmark.run[test_fn]().mean("ns") / 1e3
    m_p = str(m).split(".")
    m_s = m_p[0] + "." + m_p[1][0:2] + " " + mu + " "
    result = "result: " + str(int(r.load[width=1]()))
    a = m_s + result
    return a
