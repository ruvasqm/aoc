#!/usr/bin/env mojo
import os

fn main() raises:
  with open("./2024_input1_1.txt", "r") as f:
    var list1 = List[Int32]()
    var list2 = List[Int32]()
    for i in range(0,1000):
      list1.append(atol(f.read(5)))
      _ = f.seek(3, os.SEEK_CUR)
      list2.append(atol(f.read(5)))
      _ = f.seek(1, os.SEEK_CUR)
    sort(list1)
    sort(list2)

    var accumulator: Int32 = 0
    var similarity_score = SIMD[DType.int32,1024]()
    var vec1 = SIMD[DType.int32,1024]()
    try:
      for i in range(list1.size):
        accumulator += abs(list1[i]-list2[i])
        vec1[i] = list1[i]
        for j in range(list2.size):
          if (list2[j] == list1[i]):
            similarity_score[i] += 1
    finally:
      print(accumulator)
      print((vec1*similarity_score).reduce_add())
