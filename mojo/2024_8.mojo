from sys import argv
from os import path
from collections import Dict
from collections import Set


fn main() raises:
    if len(argv()) == 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = String(argv()[0]).split(".")[0] + "." + mode
        with open(filename, "rb") as f:
            var s = f.read().split("\n")
            _ = s.pop()
            process(s)


fn process(l: List[String]) raises:
    n = len(l)
    m = len(l[len(l) - 1])
    debug_assert(n == m, "FUCK1")
    freq = Dict[String, List[SIMD[DType.int16, 2]]]()
    result = List[SIMD[DType.int16, 2]]()
    results2 = List[Int]()
    for y in range(n):
        for x in range(n):
            if l[y][x] == ".":
                continue
            if not l[y][x] in freq:
                freq[l[y][x]] = List[SIMD[DType.int16, 2]]()
            freq[l[y][x]].append(SIMD[DType.int16, 2](y, x))
            for i in range(len(freq[l[y][x]]) - 1):
                a = SIMD[DType.int16, 2](y, x)
                da = freq[l[y][x]][i] - a
                a1 = a - da
                a2 = a + 2 * da
                if all(a1 >= 0) and all(a1 < n):
                    if len(result) == 0:
                        result.append(a1)
                    for i in range(len(result)):
                        if all(result[i] == a1):
                            break
                        elif i == len(result) - 1:
                            result.append(a1)
                if all(a2 >= 0) and all(a2 < n):
                    if len(result) == 0:
                        result.append(a2)
                    for i in range(len(result)):
                        if all(result[i] == a2):
                            break
                        elif i == len(result) - 1:
                            result.append(a2)
                i = 1
                f = a - i*da
                b = a + i*da
                scanf = scanb = True
                while scanf or scanb:
                  #print("iter:",i, l[y][x],a, i*da, f, b)
                    scanf = (all(f >=0) and all(f <n))
                    scanb = (all(b>=0) and all(b<n))
                    if scanf:
                      if l[int(f[0])][int(f[1])] == ".":
                        #print("adding",l[y][x],y, x , str(f))
                        if int(f[0]*n + f[1]) not in results2:
                          results2.append(int(f[0]*n+f[1]))
                    if scanb:
                      if l[int(b[0])][int(b[1])] == ".":
                        #print("adding",l[y][x],y, x , str(b))
                        if int(b[0]*n + b[1]) not in results2:
                          results2.append(int(b[0]*n+b[1]))
                    i +=1
                    b += da
                    f -= da
    print("result", len(result))
    p2 = len(results2)
    for f in freq:
      p2+= len(freq[f[]])
    print("result2", p2)
