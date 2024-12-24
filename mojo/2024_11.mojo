#!/usr/bin/env mojo
# fg : \033[38;2;<r>;<g>;<b>m
# bg : \033[48;2;<r>;<g>;<b>m
import benchmark
from sys import argv
from os import path
from memory import memset_zero
from collections import Dict
from collections import Set
from math import log

alias AoCResult = UnsafePointer[Scalar[DType.uint64]]
alias AoCPart = fn (List[String], AoCResult) raises -> None
alias StoneChild = SIMD[DType.int64, 2]
alias Stone = SIMD[DType.int64, 1]
alias MAX_STONES = 3 * (2**14)
alias MAX_DEPTH = 75
alias mu = "μs"

fn p1(l: List[String], r: AoCResult) raises -> None:
    items = List[Stone]()
    items.reserve(42069)
    raws = l[0].split(" ")

    for i in range(len(raws)):
        x = apply_rules(atol(raws[i]))
        for j in range(2):
            if x[j] != -1:
                items.insert(len(items), x[j])

    for _ in range(24):
        bound = len(items)
        j = 0
        while j < bound:
            x = apply_rules(items[j])
            items[j] = x[0]
            if x[1] > -1:
                j += 1
                items.insert(j, x[1])
            j += 1
            bound = len(items)
    items.clear()
    raws.clear()

    r.store[width=1](len(items))


fn apply_rules(i: Stone) raises -> StoneChild:
    if i == 0:
        return StoneChild(1, -1)
    elif len(str(i)) % 2 == 0:
        k = len(str(i))
        return StoneChild( i // (10 ** (k // 2)),  i % (10 ** (k // 2)))
    else:
        return StoneChild(i * 2024, -1)

struct Tree[l : Int = MAX_STONES, m :Int = MAX_DEPTH]:
    var data: UnsafePointer[Stone]
    var depths: UnsafePointer[Stone]
    var computed: Dict[Int, Int]
    var created: Dict[Int, Int]
    var tail: UnsafePointer[Int]

    # Initialize zeroeing all values
    fn __init__(inout self):
        self.data = UnsafePointer[Stone].alloc(l)
        memset_zero(self.data.address, l )
        self.depths = UnsafePointer[Stone].alloc(m*l)
        memset_zero(self.depths.address, m*l)
        self.tail = UnsafePointer[Int].alloc(1)
        memset_zero(self.tail.address, 1)
        self.computed = Dict[Int,Int](power_of_two_initial_capacity = 8192)
        self.created = Dict[Int,Int](power_of_two_initial_capacity = 8192)

    fn free(inout self):
      self.data.free()
      self.depths.free()
      self.tail.free()
      self.computed.clear()
      self.created.clear()


    fn get_childs(self, idx: Int) -> Tuple[Int, Int]:
      lc_idx = int(self.data.load[width=1](idx*3+1))
      rc_idx = int(self.data.load[width=1](idx*3+2))
      return (lc_idx, rc_idx)

    fn __getitem__(self, idx:Int) -> Int:
      return int(self.data.load[width=1](idx*3))


    fn walk(inout self, i: Stone, d : Int) raises -> Int:
      if d == 0:
        return 1
      if int(i) in self.computed:
        s_idx = self.computed[int(i)]
        s_weigth = int(self.depths.load[width=1](s_idx*m+d))
        #print("pre: im", i , "and my weight at", d, "is", self.depths.load[width=1](s_idx*m+d))
        if s_weigth != 0:
          return s_weigth
        else:
          children = self.get_childs(s_idx)
          #print(children[0], children[1])
          lc_weight = self.walk(self[children[0]], d - 1)
          rc_weight = 0
          if children[1] != -1:
            rc_weight = self.walk(self[children[1]], d-1)
          self.depths.store[width=1](s_idx*m+d, lc_weight + rc_weight )
          #print("im", i , "and my weight at", d, "is", self.depths.load[width=1](s_idx*m+d))
          return int(self.depths.load[width=1](s_idx*m+d))
      else:
        # please remmeber that we need to do this gradually
        # do we initialize the childs's childs? what value represents that?
        if not int(i) in self.created:
          new = Stone(i)
          #print("init tail",  self.tail[])
          if self.tail[]+3 == MAX_STONES:
            raise("Oh Fuck")
          self.data.store[width=1](self.tail[]*3,new)
          self.data.store[width=1](self.tail[]*3+1,-1)
          self.data.store[width=1](self.tail[]*3+2,-1)
          self.created[int(i)] = self.tail[]
          #print("Initiating parent", i, "current tail")
          self.tail[] += 3

        p_idx = self.created[int(i)]
        ch = apply_rules(i)
        #print(ch)
        lch = int(ch[0])
        rch = int(ch[1])
        lch_idx = self.tail[]
        #print("creating left child", lch,lch_idx)
        self.data.store[width=1](lch_idx*3, ch[0])
        self.data.store[width=1](lch_idx*3+1,-1)
        self.data.store[width=1](lch_idx*3+2,-1)
        self.data.store[width=1](p_idx*3+1, lch_idx)
        self.created[lch] = lch_idx
        self.tail[] += 3

        if rch == -1:
          self.computed[int(i)]  = self.created.pop(int(i))
          return self.walk(lch, 0 if d == 0 else d-1)
        rch_idx = self.tail[]
        #print("creating right child", rch, rch_idx)
        self.data.store[width=1](rch_idx*3, ch[1])
        self.data.store[width=1](rch_idx*3+1,-1)
        self.data.store[width=1](rch_idx*3+2,-1)
        self.data.store[width=1](p_idx*3+2, rch_idx)
        self.created[rch] = rch_idx
        #print("maubl", i, len(self.computed))
        self.computed[int(i)]  = self.created.pop(int(i))
        #print("maubl not")
        self.tail[] += 3
        s_weight =  self.walk(lch, 0 if d == 0 else d-1) + self.walk(rch, 0 if d == 0 else d-1)
        self.depths.store[width=1](p_idx*m+d, s_weight )
        return s_weight

fn p2(l: List[String], r: AoCResult) raises -> None:
    tree = Tree()
    items = List[Stone]()
    raws = l[0].split(" ")
    total = 0

    for i in range(len(raws)):
        x = apply_rules(atol(raws[i]))
        for j in range(2):
            if x[j] != -1:
                items.insert(len(items), x[j])
    iters = MAX_DEPTH
    for k in range(iters):
      #print("Entering iter", k)
      for i in range(len(items)):
          _ = tree.walk(items[i], k)
      if k == iters - 1:
        for i in range(len(items)):
          total += tree.walk(items[i], k)
    tree.free()
    items.clear()
    raws.clear()
    r.store[width=1](total)


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
        except:
            print("IAAAA ONIICHAN")
        pass

    m = benchmark.run[test_fn]().mean("ns") / 1e3
    m_p = str(m).split(".")
    m_s = m_p[0] + "." + m_p[1][0:2] + " " + mu + " "
    result = "result: " + str(int(r.load[width=1]()))
    a = m_s + result
    return a
