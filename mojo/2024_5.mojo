from sys import argv
from os import path


fn main() raises:
    if len(argv()) == 2:
        var arg = String(argv()[1])
        var mode = arg if arg == "input" else "test"
        var filename = String(argv()[0]).split(".")[0]+"." + mode
        with open(filename, "rb") as f:
            s = f.read().split("\n")
            _ = s.pop()
            process(s)


@value
struct Cock:
    var item: Int
    var rules: SIMD[DType.uint64, 2]


fn cmp_rule(a: Cock, b: Cock) capturing -> Bool:
    x = 0 if a.item <= 64 else 1
    y = SIMD[DType.uint64, 1](1) << (a.item-1)
    return (y & b.rules[x]) == 0
    # pa = pop_count(a.rules[0])+pop_count(a.rules[1])
    # pb = pop_count(b.rules[0])+pop_count(b.rules[1])
    # return pa < pb
    """
    if a.rules[1] > b.rules[1]:
        return True
    elif a.rules[0] > b.rules[0]:
        return True
    else:
        return False
    """

fn process(s: List[String]) raises:
    print("startus")
    var rules_end = 0
    var rules = SIMD[DType.uint64, 256]()
    alias max_pages = 24
    result = 0
    result2 = 0
    for i in range(len(s)):
        if len(s[i]) == 0:  # dumb af
            rules_end = i + 1
        elif rules_end == 0:
            # print(atol(s[i][0:2])) # 2 not included
            idx = atol(s[i][0:2])
            rule = atol(s[i][3:])
            # print(idx, rule, sep=" ")
            if rule <= 64:
                rules[idx * 2] |= SIMD[DType.uint64, 1](1) << (rule - 1)
                """
                for i in range(0, len(bin(rules[idx*2]))):
                  if bin(rules[idx*2])[i] == "1":
                    print("bin ", len(bin(rules[idx*2]))-i)
                """
            elif rule < 100:
                rules[idx * 2 + 1] |= SIMD[DType.uint64, 1](1) << (rule - 65)
                """
                for i in range(0, len(bin(rules[idx*2+1]))):
                  if bin(rules[idx*2+1])[i] == "1":
                    print("bin ", len(bin(rules[idx*2+1]))-i+64 )
                """
            else:
                print("FUCKKKLLKKKK")
        else:
            p = s[i].split(",")
            p.reverse()
            u = List[Cock]()
            for q in range(len(p)):
              item= atol(p[q])
              r = SIMD[DType.uint64, 2](rules[item * 2], rules[item * 2 + 1])
              u += List[Cock](Cock(item, r))
            acc = SIMD[DType.uint64, 2](0, 0)
            valid = True
            for j in range(len(u)):
                a = u[j].item
                shift = a - (1 if a <= 64 else 65)
                b = SIMD[DType.uint64, 1](1) << shift
                # print(a, bin(b), sep = " ")
                # print(bin(rules[a*2]), bin(rules[a*2+1]), sep = " ")
                if a <= 64 and ((b & acc[0]) == 0):
                    acc[0] |= rules[a * 2]
                    acc[1] |= rules[a * 2 + 1]
                elif a > 64 and ((b & acc[1]) == 0):
                    acc[1] |= rules[a * 2 + 1]
                    acc[0] |= rules[a * 2]
                else:
                    valid = False
                    # print("rule break at:", (i-rules_end), a, sep = " ")
                    # print("list ", s[i])
                    # print("acc ", end =" ")
                    # b0 = bin(acc[0], prefix="")
                    # b1 = bin(acc[1], prefix="")
                    # print(b0)
                    # print(b1)
                    #failed += List[Int](i - rules_end)
                    sort[type=Cock, stable=False, cmp_fn=cmp_rule](u)
                    result2 += u[len(u)//2].item

                    """
                for i in range(0, len(b1)):
                  if b1[i] == "1":
                    print(len(b1)-i+64, end=" ")
                for i in range(0,len(b0)):
                  if b0[i] == "1":
                    print(len(b0)-i, end=" ")
                print()
                """
                    break
            if valid:
                """
                print()
                print(
                    "adding",
                    atol(u[len(u) // 2]),
                    len(u) // 2,
                    i - rules_end,
                    sep=" ",
                )
                print(s[i])
                print()
                """
                result += u[len(u) // 2].item
    print("allegedly: ", result)
    print("part2", result2)
