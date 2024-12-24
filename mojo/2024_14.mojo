#!/usr/bin/env mojo
# fg : \033[38;2;<r>;<g>;<b>m
# bg : \033[48;2;<r>;<g>;<b>m
import benchmark
from sys import argv
from os import path
from memory import memset_zero
from sys import is_defined
from math import lcm
from algorithm import variance
from algorithm import mean
from buffer import Buffer

alias AoCResult = UnsafePointer[Scalar[DType.uint64]]
alias AoCPart = fn(List[String], AoCResult) raises -> None
alias mu = "μs"


alias w = 11  if is_defined["TEST"]() else 101
alias h = 7  if is_defined["TEST"]() else 103

struct Robot:
  var p: SIMD[DType.int16,2]
  var v: SIMD[DType.int16,2]

  fn __init__(inout self, x:Int, y:Int, vx:Int, vy:Int):
    self.p = SIMD[DType.int16,2](x,y)
    self.v = SIMD[DType.int16,2](vx,vy)

  fn __copyinit__(inout self: Self, existing: Self ):
    self.p = existing.p
    self.v = existing.v

  fn __moveinit__(inout self: Self, owned existing: Self ):
    self.p = existing.p
    self.v = existing.v

  fn move(inout self) -> SIMD[DType.int16,4]:
    next = self.p + self.v
    if next[0] < 0:
      next[0] += w
    elif next[0] >= w:
      next[0] -= w
    if next[1] < 0:
      next[1] += h
    elif next[1] >= h:
      next[1] -= h
    self.p = next
    if next[0] < w //2:
      if next[1] < h //2:
        return SIMD[DType.int16,4](next[0],next[1],0,0)
      elif next[1] > h //2:
        return SIMD[DType.int16,4](next[0],next[1],0,2)
      else:
        return SIMD[DType.int16,4](next[0],next[1],0,-1)
    elif next[0] > w //2:
      if next[1] < h //2:
        return SIMD[DType.int16,4](next[0],next[1],0,1)
      elif next[1] > h //2:
        return SIMD[DType.int16,4](next[0],next[1],0,3)
      else:
        return SIMD[DType.int16,4](next[0],next[1],0,-1)
    else:
      return SIMD[DType.int16,4](next[0],next[1],0,-1)



fn p1(l: List[String], r: AoCResult) raises -> None:
    n = len(l)
    alias final_time = 100
    robots = List[Robot]()
    total = 0
    for i in range(n):
      _i = l[i].split(' ')
      _p = _i[0].split('=')
      _px = atol(_p[1].split(',')[0])
      _py = atol(_p[1].split(',')[1])
      _v = _i[1].split('=')
      _vx = atol(_v[1].split(',')[0])
      _vy = atol(_v[1].split(',')[1])
      #print(_px, _py, _vx, _vy)
      robots.append(Robot(_px,_py,_vx,_vy))

    for _ in range(final_time):
      quadrants = List[Int](0,0,0,0)
      for j in range(len(robots)):
        #print("moving robot", j, robots[j].p,robots[j].v)
        q = robots[j].move()
        #print("moved robot", j, robots[j].p,robots[j].v, q)
        if q[3] != -1:
          quadrants[int(q[3])] += 1
      total = quadrants[0]*quadrants[1]*quadrants[2]*quadrants[3]
      #print(i, "Safety factor:", total)

    r.store[width=1](total)

fn p2(l: List[String], r: AoCResult) raises -> None:
    alias test = True if is_defined["TEST"]() else False
    if test:
      print("Not sure about testing this one Doc")
      return
    n = len(l)
    alias max_iters = 10000
    robots = List[Robot]()
    total = 0
    for i in range(n):
      _i = l[i].split(' ')
      _p = _i[0].split('=')
      _px = atol(_p[1].split(',')[0])
      _py = atol(_p[1].split(',')[1])
      _v = _i[1].split('=')
      _vx = atol(_v[1].split(',')[0])
      _vy = atol(_v[1].split(',')[1])
      robots.append(Robot(_px,_py,_vx,_vy))

    state = Tuple[Int,Int](215476074,0)
    cnt = 0
    for i in range(max_iters):
      init = state[1]
      quadrants = List[Int](0,0,0,0)
      for j in range(len(robots)):
        #print("moving robot", j, robots[j].p,robots[j].v)
        q = robots[j].move()
        #print("moved robot", j, robots[j].p,robots[j].v, q)
        if q[3] != -1:
          quadrants[int(q[3])] += 1

      sec= quadrants[0]*quadrants[1]*quadrants[2]*quadrants[3]
      if sec < state[0]:
        state = Tuple(sec, i+1)
        cnt=0
      elif state[1] == init:
        cnt+=1
      elif cnt > 1000:
        total = state[1]
        break

    total = state[1]
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
