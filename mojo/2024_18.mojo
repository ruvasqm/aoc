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

fn p1(l: List[String], r: AoCResult) raises -> None:
    n = len(l)
    total = 0

    for i in range(0,n,4):
          m = UnsafePointer[SIMD[DType.uint64,1]].alloc(4)
          memset_zero(m.address, 4)
          _ca = l[i].split(',')
          _xa = atol(_ca[0].split('+')[1])
          _ya = atol(_ca[1].split('+')[1])
          _cb = l[i+1].split(',')
          _xb = atol(_cb[0].split('+')[1])
          _yb = atol(_cb[1].split('+')[1])
          _cp = l[i+2].split(',')
          _xp = atol(_cp[0].split('=')[1])
          _yp = atol(_cp[1].split('=')[1])
          #print(_xa, _ya, _xb, _yb, _xp, _yp)
          m.store[width=4](0, SIMD[DType.uint64,4](_xa, _xb, _ya, _yb))
          det = _xa * _yb - _xb * _ya
          if det == 0:
            print("no can do")
            continue
          else:
            a = (_yb *_xp - _xb * _yp) // det
            b = (-_ya *_xp + _xa * _yp) //det
            if a*_xa+b*_xb == _xp and a*_ya+b*_yb==_yp:
              #print(i, a,b, a*3 + b*1 )
              total += a*3 + b*1

    r.store[width=1](total)

fn p2(l: List[String], r: AoCResult) raises -> None:
    alias error = 10000000000000
    n = len(l)
    total = 0

    for i in range(0,n,4):
          m = UnsafePointer[SIMD[DType.uint64,1]].alloc(4)
          memset_zero(m.address, 4)
          _ca = l[i].split(',')
          _xa = atol(_ca[0].split('+')[1])
          _ya = atol(_ca[1].split('+')[1])
          _cb = l[i+1].split(',')
          _xb = atol(_cb[0].split('+')[1])
          _yb = atol(_cb[1].split('+')[1])
          _cp = l[i+2].split(',')
          _xp = atol(_cp[0].split('=')[1])+error
          _yp = atol(_cp[1].split('=')[1])+error
          #print(_xa, _ya, _xb, _yb, _xp, _yp)
          m.store[width=4](0, SIMD[DType.uint64,4](_xa, _xb, _ya, _yb))
          det = _xa * _yb - _xb * _ya
          if det == 0:
            print("no can do")
            continue
          else:
            a = (_yb *_xp - _xb * _yp) // det
            b = (-_ya *_xp + _xa * _yp) //det
            if a*_xa+b*_xb == _xp and a*_ya+b*_yb==_yp:
              #print(i, a,b, a*3 + b*1 )
              total += a*3 + b*1

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
