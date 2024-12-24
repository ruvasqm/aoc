from sys import argv
from os import path
from collections import Dict
from bit import pop_count


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
    result = 0
    result2 = 0
    for i in range(len(l)):
        print("line: ", i)
        vals = l[i].split(" ")
        r = atol(vals[0].replace(":", ""))
        pops = vals[1:]
        ops = List[Int]()
        for j in range(len(pops)):
            ops.append(atol(pops[j]))
        ini = result
        p = SIMD[DType.uint64, 1](2 ** (len(ops) - 1))
        for k in range(p):
            partial = ops[0]
            for j in range(1, len(ops)):
                if any(k & (SIMD[DType.uint64, 1](1) << (j - 1))):
                    partial *= ops[j]
                else:
                    partial += ops[j]
            if partial == r:
                result += partial
                break
        if ini == result:
            t = SIMD[DType.uint64, 1](3 ** (len(ops) - 1))
            for k in range(t):
                partial = ops[0]
                for j in range(1, len(ops)):
                  #print("s",k % 3)
                  if (k // (3**(j-1)))%3 == 0:
                    partial *= ops[j]
                  if (k // (3**(j-1)))%3 == 1:
                    partial += ops[j]
                  if (k // (3**(j-1)))%3 == 2:
                    partial = atol(str(partial) + str(ops[j]))
                if partial == r:
                    result2 += partial
                    break
                #print()
        print(i)
    print("result: ", result)
    print("result2: ", result2+result)
