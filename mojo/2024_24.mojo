#!/usr/bin/env mojo
# fg : \033[38;2;<r>;<g>;<b>m
# bg : \033[48;2;<r>;<g>;<b>m
import benchmark
from sys import argv
from os import path
from memory import memset_zero
from sys import is_defined
from collections import Dict

alias AoCResult = UnsafePointer[Scalar[DType.uint64]]
alias AoCPart = fn(List[String], AoCResult) raises -> None
alias mu = "μs"


#alias  if is_defined["TEST"]() else

fn p1(l: List[String], r: AoCResult) raises -> None:
    total = 0
    half = 0
    var signals = Dict[String, Int]()
    while len(l[half]) > 3:
      parts = l[half].split(':')
      signals[parts[0]] = atol(parts[1])
      half += 1
    #print(half, l[half+1].split("->")[0])
    rest = l[half+1::]
    while len(rest) != 0:
      for i in range(len(rest)):
        lh = rest[i].split("->")[0]
        rh = rest[i].split("->")[1].replace(' ', '')
        a = lh.split(" ")[0].replace(' ', '')
        op = lh.split(" ")[1].replace(' ', '')
        b = lh.split(" ")[2].replace(' ', '')
        #print(a , op, b, "B=D", rh)
        if a in signals and b in signals:
          if op == "OR":
            signals[rh] = signals[a] | signals[b]
          elif op == "XOR":
            signals[rh] = signals[a] ^ signals[b]
          elif op == "AND":
            signals[rh] = signals[a] & signals[b]
          _ =rest.pop(i)
          break
    for e in signals:
      if "z" in e[]:
        print(e[], signals[e[]])
        sft = atol(e[].replace('z',''))
        total |= (signals[e[]] << sft)
    r.store[width=1](total)

fn p2(l: List[String], r: AoCResult) raises -> None:
    total = 0
    r.store[width=1](total)

fn main() raises:
    alias mode = "test" if is_defined["TEST"]() else "input"
    var filename = String(argv()[0]).replace("mojo", mode)
    var result = AoCResult.alloc(1)
    memset_zero(result.address, 1)
    var result2 = AoCResult.alloc(1)
    var s = List[String]()
    memset_zero(result2.address, 1)
    with open(filename, "rb") as f:
        var input = f.read().splitlines()
        s = input
    if is_defined["BENCH"]():
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
      except:
        print("IAAAA ONIICHAN")
      pass

    m = benchmark.run[test_fn]().mean("ns") / 1e3
    m_p = str(m).split(".")
    m_s = m_p[0] + "." + m_p[1][0:2] + " " + mu + " "
    result = "result: " + str(int(r.load[width=1]()))
    a = m_s + result
    return a
