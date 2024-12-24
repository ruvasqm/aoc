#!/usr/bin/env mojo
import os
from sys import argv


fn main() raises:
    if len(argv()) == 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = "./2024_2." + mode
        hell(filename)
"""

fn jigokuraku(filename: String) raises:
    with open(filename, "r") as f:
        var lines = f.read().split("\n")
        for i in range(0, lines.size):
            var words = lines[i].as_bytes_slice()
            print(words[0])


fn heaven(filename: String) raises:
    with open(filename, "r") as f:
        var lines = f.read_bytes()
        var i = -1
        while i < lines.size:
            i = i + 1
            # print(lines[i], end=" ")
            var n = SIMD[DType.uint8, 2](48, 48)
            var offset = SIMD[DType.uint8, 2](48, 48)
            var metric = SIMD[DType.uint8, 2](10, 1)
            while (
                lines[i] != ord(" ")
                and i < lines.size
                and lines[i] != ord("\n")
            ):  # secure buttaccess
                # print(ord(" "), lines[i], sep=" ")
                n = n.shift_left[1]()
                n[1] = lines[i]
                i = i + 1
            if lines[i] != 10:
                print(((n - offset) * metric).reduce_add(), end=" ")
        print("")
"""

fn hell(filename: String) raises:
    with open(filename, "r") as f:
        var lines = f.read().split("\n")
        _ = lines.pop()
        var safe = lines.size
        var pot_safe = 0
        for l in range(0, len(lines)):
            var s = lines[l].split(" ")
            c = check(s)
            if not c:
              #print("line ", l, ":", end="")
                safe -= 1
                ppot_safe = False
                for i in range(0, s.size):
                  var new_s = s
                  _ = new_s.pop(i)
                  #for k in range(0,new_s.size):
                    #print(new_s[k], end = "")
                  #print("")
                  if check(new_s):
                    ppot_safe = True
                if ppot_safe:
                  pot_safe += 1



        print("There are ", safe, " safe lines")
        print("There are ", pot_safe + safe, " potentially safe lines")



fn check(s: List[String]) raises -> Bool:
    fn dir(a: Int, b: Int) -> Int:
        return a - b

    start_dir = dir(atol(s[0]), atol(s[1]))
    var is_safe = True
    for i in range(1, s.size):
        curr_dir = dir(atol(s[i - 1]), atol(s[i]))
        if 1 <= abs(curr_dir) <= 3:
            if curr_dir < 0 and start_dir < 0 or curr_dir > 0 and start_dir > 0:
                pass
            else:
                is_safe = False
                #print("INFRACTION of interval ", "word: ", i)
        else:
            is_safe = False
            #print("INFRACTION of size", " word: ", i)
    return is_safe
