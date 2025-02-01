#!/usr/bin/env mojo
# fg : \033[38;2;<r>;<g>;<b>m
# bg : \033[48;2;<r>;<g>;<b>m
import benchmark
from sys import argv
from os import path
from memory import memset_zero
from sys import is_defined

alias AoCResult = UnsafePointer[Scalar[DType.uint64]]
alias AoCPart = fn(List[String], AoCResult) raises -> None
alias mu = "μs"


#alias  if is_defined["TEST"]() else
struct Computer:
  var A: Int
  var B: Int
  var C: Int
  var IP: Int
  var program: List[Int]
  var output: String

  alias adv = 0
  alias bxl = 1
  alias bst = 2
  alias jnz = 3
  alias bxc = 4
  alias out = 5
  alias bdv = 6
  alias cdv = 7

  fn __init__(inout self, A: Int, B: Int, C:Int, p: List[Int]):
    self.A = A
    self.B = B
    self.C = C
    self.IP = 0
    self.program = List[Int](p)
    self.output = String("")

  fn combo(self, n: Int) raises -> Int:
    if n < 4:
      return n
    elif n ==4:
      return self.A
    elif n ==5:
      return self.B
    elif n ==6:
      return self.C
    else:
     raise("NOO")

  fn exec(inout self, ins: Int, op: Int) raises -> Int:
    if ins == self.adv:
      self.A = self.A // (2**self.combo(op))
      return self.IP + 2
    elif ins == self.bxl:
      self.B ^= op
      return self.IP + 2
    elif ins == self.bst:
      self.B = self.combo(op) % 8
      return self.IP + 2
    elif ins == self.jnz:
      return op if self.A !=0 else self.IP +2
    elif ins == self.bxc:
      self.B ^= self.C
      return self.IP + 2
    elif ins == self.out:
      self.output += str(self.combo(op) % 8) + ','
      return self.IP + 2
    elif ins == self.bdv:
      self.B = self.A // (2**self.combo(op))
      return self.IP + 2
    elif ins == self.cdv:
      self.C = self.A // (2**self.combo(op))
      return self.IP + 2
    else:
      raise("WTFFF")

  fn run(inout self) raises -> String:
      while self.IP < len(self.program) -1:
        #print(self.program[self.IP], self.program[self.IP+1], self.A, self.B, self.C, " ||", end=" ")
        #for i in range(len(self.output)):
        #  print (self.output[i], end="")
        #print()
        next = self.exec(self.program[self.IP], self.program[self.IP+1])
        self.IP = next
      return self.output


fn p1(l: List[String], r: AoCResult) raises -> None:
    total = 0
    var A = atol(l[0].split(':')[1])
    var B = atol(l[1].split(':')[1])
    var C = atol(l[2].split(':')[1])
    var _p = l[-1].split(' ')[1].split(',')
    var program = List[Int]()

    for i in range(len(_p)):
      program.append(atol(_p[i]))

    var mc = Computer(A, B, C, program)
    print(mc.run()[0:-1])

    r.store[width=1](total)

fn p2(l: List[String], r: AoCResult) raises -> None:
    res = 0
    var _p = l[-1].split(' ')[1].split(',')
    var program = List[Int]()

    for i in range(len(_p)):
      program.append(atol(_p[i]))

    ass = List[Int](0)
    j = len(program) -1
    while len(program) != 0:
      subass = List[Int]()
      for i in range(8): # fu
        for k in range(len(ass)):
          a = i + ass[k]
          b = (((a & 7 ^ 7) ^ (a >> (a & 7 ^7)))^7) & 7
          if b == program[j]:
            subass.append( a << 3)
      ass = subass
      j -=1
      if j == -1:
        m = ass[-1]
        for p in range(len(ass)):
          if ass[p] < m:
            m = ass[p]
            break
        res = m // 8
        break

    r.store[width=1](res)

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
