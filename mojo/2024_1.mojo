#!/usr/bin/env mojo
import os
from buffer import Buffer
# simdwidthof = number of float32 elements that fit into a single SIMD register
# using a 2x multiplier allows some SIMD operations to run in the same cycle
fn chunk_it(filename: String):
  alias buffer1 = Buffer[DType.uint8]
  try:
    with open(filename, "r") as f:
      f.
      buffer1.store[width=8](0, f.read(8)._buffer.data)
  except:
    print("You are a moron and can't even read a file with a language from the future")

fn main():
  chunk_it("./2024_input1_1.txt")
