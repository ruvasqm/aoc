from sys import argv


fn main() raises:
    if len(argv()) == 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = "./2024_4." + mode
        print("\033[94mstarting\033[0m")
        with open(filename, "rb") as f:
            print("\033[94mreading\033[0m")
            s = f.read().split("\n")
            _ = s.pop()
            print("\033[94mread\033[0m")
            process(s)


fn process(s: List[String]):
    alias xmas = "XMAS"
    alias samx = "SAMX"
    alias mas = "MAS"
    alias sam = "SAM"
    debug_assert(len(xmas) == len(samx), "FUCK1")
    m = len(s[0])
    n = len(s)
    debug_assert(m == n, "FUCK2")
    result = 0
    result2 = 0
    for j in range(n) :
      for i in range(n):
        if i < (n - len(samx) + 1 ):
          if s[j][i:i+len(xmas)] == xmas:
            result += 1
          if s[j][i:i+len(samx)] == samx:
            result += 1
          #print(i, j, s[j][i:i+len(xmas)], result, "H" , sep=" ")
        if j < (m - len(samx) + 1 ):
          #print("inside your mom")
          v = s[j][i] + s[j+1][i] + s[j+2][i]+ s[j+3][i]
          if v == xmas:
            result += 1
          if v == samx:
            result += 1
          #print(i, j, v, result, "V", sep=" ")
          if i < (n - len(samx) + 1 ):
            d = s[j][i] + s[j+1][i+1] + s[j+2][i+2]+ s[j+3][i+3]
            if d == samx:
              result += 1
            if d == xmas:
              result += 1
            #print(i, j, d, result, "D", sep=" ")
            ds = s[j][i+3] + s[j+1][i+2] + s[j+2][i+1]+ s[j+3][i+0]
            if ds == samx:
              result += 1
            if ds == xmas:
              result += 1
            #print(i, j, ds, result, "S", sep=" ")
        if j < (n- len(sam) + 1) and i< (n- len(sam) + 1):
            d = s[j][i] + s[j+1][i+1] + s[j+2][i+2]
            sr = 0
            if d == sam:
              sr += 1
            if d == mas:
              sr += 1
            ds = s[j][i+2] + s[j+1][i+1] + s[j+2][i]
            if ds == sam:
              sr += 1
            if ds == mas:
              sr += 1
            if sr > 1:
              result2 += 1
      print()
    print("result: ", result, " result2: ", result2)
