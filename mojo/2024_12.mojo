#!/usr/bin/env mojo
# fg : \033[38;2;<r>;<g>;<b>m
# bg : \033[48;2;<r>;<g>;<b>m
import benchmark
from sys import argv
from os import path
from memory import memset_zero
from collections import Set
from sys import simdwidthof
from utils import Span
from sys import is_defined
from collections import Dict

alias AoCResult = UnsafePointer[Scalar[DType.uint64]]
alias AoCPart = fn (Span[char], AoCResult) raises -> None
alias mu = "μs"

alias n = 11 if is_defined["TEST"]() else 141
alias w = simdwidthof[DType.uint8]()
alias nelts = round2(min(n, w))
alias step = min(n, w)
alias MAX_SIZE = n * (n - 1)
alias PADDED_SIZE = round2(n + MAX_SIZE + nelts)
alias MAX_REGIONS = 2**11
alias char = SIMD[DType.uint8, 1]
alias Vec = SIMD[DType.int16, 2]


fn round2(i: Int) -> Int:
    p = 0
    while 2**p < i:
        p += 1
    return 2**p


struct Region:
    var els: UnsafePointer[Int]
    var edges: Int
    var parent: Int
    var tail: Int
    var valid: Bool

    fn __init__(inout self):
        self.els = UnsafePointer[Int].alloc(n*n)
        memset_zero(self.els.address, n*n)
        self.edges = 0
        self.parent = -1
        self.tail = 0
        self.valid = True

    fn __copyinit__(inout self, existing: Self):
        self.els = existing.els
        self.tail = existing.tail
        self.edges = existing.edges
        self.parent = existing.parent
        self.valid = True

    fn __moveinit__(inout self, owned existing: Self):
        self.els = existing.els
        self.tail = existing.tail
        self.edges = existing.edges
        self.parent = existing.parent
        self.valid = True

    fn __eq__(self, b: Self) -> Bool:
        return self.parent == b.parent

    fn store(inout self, i: Int):
      self.els[self.tail] = i
      self.tail += 1

fn p1(l: Span[char], r: AoCResult) raises -> None:
    var edges = UnsafePointer[char].alloc(PADDED_SIZE)
    memset_zero(edges.address, PADDED_SIZE)
    var padded = UnsafePointer[char].alloc(PADDED_SIZE)
    padded.store[width=PADDED_SIZE](SIMD[DType.uint8, PADDED_SIZE](ord("\n")))
    padded.store[width=MAX_SIZE](n, l._data.load[width=MAX_SIZE]())
    regions = List[Region]()
    # debug_assert(nelts == n, "OHHFUCK")

    for i in range(n, MAX_SIZE + n, nelts):
        c = padded.load[width=nelts](i)
        f = padded.load[width=nelts](i + 1)
        b = padded.load[width=nelts](i - 1)
        d = padded.load[width=nelts](i + n)
        t = padded.load[width=nelts](i - n)
        unity = SIMD[DType.uint8, nelts](1)
        f_ne = (c != f).select(unity, 0 & unity)
        b_ne = (c != b).select(unity, 0 & unity)
        d_ne = (c != d).select(unity, 0 & unity)
        t_ne = (c != t).select(unity, 0 & unity)
        s_edge = edges.load[width=nelts](i)
        self_edges = s_edge + f_ne + d_ne + b_ne + t_ne
        edges.store[width=nelts](i, self_edges)

    parents = List[Int]()
    parents.reserve(n*n)
    for j in range(0 , (n-1)*(n-1)):
        i = j + n + j// (n-1)
        e = edges.load[width=1](i)
        if padded[i] != ord("\n"):
            bP = j -1
            uP = j -(n-1)
            if (
                padded[i] == padded[i - 1]
                and padded[i] == padded[i - n]
                and  i //n > 1
                and parents[uP] != parents[bP]
                and regions[parents[bP]].valid==True
                and regions[parents[uP]].valid==True
            ):
                # merge
                regions[parents[uP]].edges += regions[
                    parents[bP]
                ].edges
                regions[parents[uP]].edges += int(e)
                regions[parents[bP]].store(i)
                k = 0
                while k != regions[parents[bP]].tail:
                  #print(regions[parents[i -n - 1]].tail, regions[parents[i -n - 1]].edges, chr(int(padded[regions[parents[i -n - 1]].parent])))
                  if regions[parents[bP]].els[k] != 0:
                    regions[parents[uP]].store(regions[parents[bP]].els[k])
                    k+= 1
                  else:
                    break
                val = parents[bP]
                regions[parents[bP]].valid = False
                parents.append(parents[uP])
                for k in range(len(parents)):
                  if parents[k] == val:
                    parents[k] = parents[uP]
            elif padded[i] == padded[i - 1] and regions[parents[bP]].valid==True  :
                regions[parents[bP]].edges += int(e)
                regions[parents[bP]].store(i)
                parents.append(parents[bP])
            elif padded[i] == padded[i - n] and regions[parents[uP]].valid==True:
                regions[parents[uP]].edges += int(e)
                regions[parents[uP]].store(i)###
                parents.append(parents[uP])
            else:
                new = Region()
                regions.append(new)
                regions[-1].store(i)
                regions[-1].parent = i
                regions[-1].edges += int(e)
                regions[-1].valid = True
                parents.append(len(regions) - 1)

    total = 0
    sc = 0
    h = Set[Int]()
    for item in h:
        # print( "region", i, regions[i].parent // (n-1), regions[i].parent % (n-1), chr(int(padded[regions[i].parent])))
        if regions[item[]].valid:
         sc += regions[item[]].tail
         total += regions[item[]].edges * regions[item[]].tail

    # print(edges.load[width=1](j * n + i), end="")
    edges.free()
    padded.free()

    r.store[width=1](total)


fn p2(l: Span[SIMD[DType.uint8, 1]], r: AoCResult) raises -> None:
    var total = 0
    var edges = UnsafePointer[char].alloc(PADDED_SIZE)
    memset_zero(edges.address, PADDED_SIZE)
    var padded = UnsafePointer[char].alloc(PADDED_SIZE)
    padded.store[width=PADDED_SIZE](SIMD[DType.uint8, PADDED_SIZE](ord("\n")))
    padded.store[width=MAX_SIZE](n, l._data.load[width=MAX_SIZE]())

    for i in range(n, MAX_SIZE + n, nelts):
        c = padded.load[width=nelts](i)
        f = padded.load[width=nelts](i + 1)
        b = padded.load[width=nelts](i - 1)
        d = padded.load[width=nelts](i + n)
        t = padded.load[width=nelts](i - n)
        ft = padded.load[width=nelts](i-n + 1)
        fd = padded.load[width=nelts](i+n + 1)
        bt = padded.load[width=nelts](i-n -1)
        bd = padded.load[width=nelts](i+n - 1)
        unity = SIMD[DType.uint8, nelts](1)
        ft = ((c != f)&(c != t)|(c != ft)&(c == f)&(c == t)).select(unity, 0 & unity)
        fd = ((c != f)&(c != d)|(c != fd)&(c == f)&(c == d)).select(unity, 0 & unity)
        bt = ((c != b)&(c != t)|(c != bt)&(c == b)&(c == t)).select(unity, 0 & unity)
        bd = ((c != b)&(c != d)|(c != bd)&(c == b)&(c == d)).select(unity, 0 & unity)

        self_corners = fd + ft + bd + bt
        edges.store[width=nelts](i, self_corners)

    for j in range(0 ,(n-1)):
      for i in range(0 ,(n-1)):
          print(edges.load[width=1](j*n+i+n), end=" ")
      print()
    alias parent = SIMD[DType.uint64,4]
    parents = List[parent]()
    unique = List[Int]()
    unique.reserve(n*n)
    parents.reserve(n*n)
    for j in range(0 , (n-1)*(n-1)):
      i = j + n + j// (n-1)
      e = edges.load[width=1](i)
      if padded[i] != ord('\n'):
            bP = j -1
            uP = j -(n-1)
            if (
                padded[i] == padded[i - 1]
                and padded[i] == padded[i - n]
                and  i //n > 1
                and parents[uP][0] != parents[bP][0]
            ):
              parents[uP][1] += parents[bP][1] + int(e)
              parents[uP][2] += parents[bP][2] + 1
              parents.append(parents[uP])
              #print("here1")
              _ = unique.pop(unique.index(int(parents[bP][0])))
              val = parents[bP][0]
              for k in range(len(parents)):
                if parents[k][0] == val:
                  parents[k][0] = parents[uP][0]
                  parents[k][1] = parents[uP][1]
                  parents[k][2] = parents[uP][2]
                elif parents[k][0] == parents[uP][0]:
                  parents[k][0] = parents[uP][0]
                  parents[k][1] = parents[uP][1]
                  parents[k][2] = parents[uP][2]

            elif padded[i] == padded[i - 1]:
                parents[bP][1] += int(e)
                parents[bP][2] += 1
                parents.append(parents[bP])
                for k in range(len(parents)):
                  if parents[k][0] == parents[bP][0]:
                    parents[k][0] = parents[bP][0]
                    parents[k][1] = parents[bP][1]
                    parents[k][2] = parents[bP][2]
            elif padded[i] == padded[i - n]:
                parents[uP][1] += int(e)
                parents[uP][2] += 1
                parents.append(parents[uP])
                for k in range(len(parents)):
                  if parents[k][0] == parents[uP][0]:
                    parents[k][0] = parents[uP][0]
                    parents[k][1] = parents[uP][1]
                    parents[k][2] = parents[uP][2]
            else:
                parents.append(parent(int(j),int(e),1,0))
                unique.append(j)
    print(len(parents))
    for i in range(len(parents)-1, -1, -1):
        #print(parents[i],chr(int( padded[int(parents[i][0]+n+parents[i][0]//(n-1))])))
        if int(parents[i][0]) in unique:
          total += int(parents[i][1] * parents[i][2])
          #print("here2",)
          _ = unique.pop(unique.index(int(parents[i][0])))
        elif len(unique) == 0:
          break

    r.store[width=1](total)


fn main() raises:
    alias mode = "test" if is_defined["TEST"]() else "input"
    var filename = String(argv()[0]).replace("mojo", mode)
    var result = AoCResult.alloc(1)
    memset_zero(result.address, 1)
    var result2 = AoCResult.alloc(1)
    var s = List[char, 1]()
    memset_zero(result2.address, 1)
    with open(filename, "rb") as f:
        var input = f.read().as_bytes()
        s = input
    if is_defined["BENCH"]():
        print("p1 took:", bench[p1](s, result))
        print("p2 took:", bench[p2](s, result2))
    else:
        # p1(s, result)
        #print("result p1:", result.load[width=1]())
        p2(s, result2)
        print("result p2:", result2.load[width=1]())


fn bench[f: AoCPart](s: Span[char], r: AoCResult) raises -> String:
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
