from sys import argv
from os import path
from collections import Dict
from time import sleep

fn main() raises:
    if len(argv()) == 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = String(argv()[0]).split(".")[0] + "." + mode
        with open(filename, "rb") as f:
            var s = f.read().splitlines()
            process(s[0])
            process2(s[0])


fn process(l: String) raises:
    n = len(l)
    tf = n // 2 if n % 2 == 0 else n // 2 + 1
    final_blocks = List[SIMD[DType.uint64, 2]]()
    checksum = 0
    sf = ((tf - 1) * 2, atol(l[(tf - 1) * 2]))
    idx = 0
    fidx = 0
    i = 0
    while sf[1] != 0 and i < len(l):
        if i % 2 == 0:
            if i == sf[0]:
              chunk = SIMD[DType.uint64, 2](i, sf[1])
              sf = (sf[0], 0)
              #print("allocating file:", i//2 , chunk[1])
            else:
              chunk = SIMD[DType.uint64, 2](i, atol(l[i]))
              #print("allocating file:", i//2 , chunk[1])
            final_blocks.append(chunk)
        elif sf[1] != 0 and sf[0] > i:
                free = atol(l[i])
                #print("found free space", i//2, free)
                while free > 0:
                    if sf[1] <= free:
                        chunk = SIMD[DType.uint64, 2](sf[0], sf[1])
                        final_blocks.append(chunk)
                        #print("reallocating file:",sf[0]//2  , chunk[1])
                        free = free - sf[1]
                        sf = (sf[0] - 2, atol(l[sf[0] - 2]))
                        if sf[0] == i -1:
                          sf = (0 , 0)
                        #print("current sf: ", sf[0]//2, sf[1])
                    elif sf[1] > free:
                        chunk = SIMD[DType.uint64, 2](sf[0], free)
                        final_blocks.append(chunk)
                        #print("reallocating file:",sf[0]//2  , chunk[1])
                        sf = (sf[0], sf[1]-free)
                        free = 0
                        if sf[0] == i -1:
                          sf = (0 , 0)
                        #print("current sf: ", sf[0]//2, sf[1])
        for j in range(idx,len(final_blocks)):
          for _ in range(int(final_blocks[j][1])):
            id = int(final_blocks[j][0] // 2)
            #print("summing: ", fidx, id, fidx*id)
            checksum += fidx*id
            fidx += 1
          idx = len(final_blocks)
        i += 1
    print("checksum:", checksum)

fn process2(l: String) raises:
    n = len(l)
    blocks = List[SIMD[DType.uint64, 2]]()
    alias e = -1
    for i in range(n):
      if i % 2 == 0:
        chunk = SIMD[DType.uint64, 2](i // 2, atol(l[i]))
        blocks.append(chunk)
        #print("added file", i//2, atol(l[i]))
      else:
        chunk = SIMD[DType.uint64, 2](e, atol(l[i]))
        blocks.append(chunk)
        #print("added block", i//2, atol(l[i]))

    for i in range(len(blocks)-1, -1, -1):
      id =  'E' if blocks[i][0] == e else str(blocks[i][0])
      girth = blocks[i][1]
      if blocks[i][0] != e:
        for j in range(i):
          id2 = 'E' if blocks[j][0] == e else str(blocks[j][0])
          if blocks[j][0] == e:
            if blocks[j][1] == girth:
              #print("swapping",i,  id, girth, "<->",j, id2, blocks[j][1])
              blocks.swap_elements(j,i)
              break
            elif blocks[j][1] > girth:
              #print("swapping and inserting",i, id, girth, "<->",j, id2, blocks[j][1], "stub", blocks[j][1]-girth)
              stub = SIMD[DType.uint64,2](e, blocks[j][1]-girth)
              blocks.swap_elements(i,j)
              blocks[i][1] -= stub[1]
              blocks.insert(j+1, stub)
              #print(blocks[j], blocks[i], blocks[j+1])
              i += 1
              break
      """
      for k in range(len(blocks)):
        id =  '.' if blocks[k][0] == e else str(blocks[k][0])
        g = int(blocks[k][1])
        print(id *g, end="")
      print()
      """
    checksum = 0
    fidx = 0
    for k in range(len(blocks)):
        bid =  0 if blocks[k][0] == e else blocks[k][0]

        for _ in range( int(blocks[k][1])):
          checksum += int(bid) * fidx
          fidx += 1
    print("checksum2:", checksum)



