from memory import memset_zero
from sys import simdwidthof
from algorithm.functional import vectorize
from random import rand
from sys import argv

alias type = DType.uint8
alias simd_width = simdwidthof[DType.uint8]()
alias n = 140
# _____________________________________________________________________
# | 2n                    | 2n -1                | 2n -1               | -> bytes
# | 2n straights          | 2n -1 diags          | 2n -1 counter diags | -> flags
# | 0    n-1 | n     2n-1 | 2n         4n -2     | 4n -1          6n-3 |
# |_______________________|______________________|_____________________|
# i=0 i=n-1 j=0     j=n-1| x=y+k [-(n-1),(n-1)] | x=k-y [0,2n-1]
alias flags_size = 6 * n - 2
alias xmas = SIMD[type, 4](ord("X"), ord("M"), ord("A"), ord("S"))
alias samx = SIMD[type, 4](ord("S"), ord("A"), ord("M"), ord("X"))
alias flag_regions = List[String]("H", "V", "D", "S")


fn main() raises:
    print("\033[94mstarting\033[0m")
    with open("./2024_4.input", "rb") as f:
        print("\033[94mreading\033[0m")
        s = f.read()
        s = s.replace("\n", "").replace("\r", "")
        print("chars long ", len(s))
        print("\033[94mread\033[0m")
        process(s)


fn mask_f(b: SIMD[type, 1]) -> SIMD[type, 1]:
    return b & SIMD[type, 1](0x0F)


fn mask_b(b: SIMD[type, 1]) -> SIMD[type, 1]:
    return (b & SIMD[type, 1](0xF0)) >> 4


fn convert_flag(flags: SIMD[type, 1]) -> String:
    f = mask_f(flags)
    b = mask_b(flags)
    f_s = chr(int(xmas.__getitem__(int(f))))
    b_s = chr(int(samx.__getitem__(int(b))))
    return b_s + f_s


fn convert_offset(offset: Int) -> String:
    if offset < n:
        return flag_regions[0] + str(offset)
    elif offset < 2 * n:
        return flag_regions[1] + str(offset - n)
    elif offset < (4 * n - 1):
        return flag_regions[2] + str(offset - 2 * n)
    else:
        return flag_regions[3] + str(offset - (4 * n - 1))


fn log_cycle_flags(
    run_number: SIMD[DType.uint16, 1],
    c: SIMD[type, 1],
    initial_flag: String,
    result_flag: String,
    offset: Int,
):
    offset_region = convert_offset(offset)
    region_color = ""
    if offset_region.startswith("H"):
        region_color = "\033[93m"  # Yellow
    elif offset_region.startswith("V"):
        region_color = "\033[91m"  # Red
    elif offset_region.startswith("D"):
        region_color = "\033[95m"  # Magenta
    elif offset_region.startswith("S"):
        region_color = "\033[96m"  # Cyan
    else:
        region_color = "\033[90m"  # Default to gray

    print(
        region_color,
        "run",
        run_number,
        chr(int(c)),
        initial_flag,
        result_flag,
        offset_region,
        "\033[0m",
    )


fn process(s: String):
    print("\033[94minitializing flags\033[0m")
    flags = UnsafePointer[Scalar[type]].alloc(flags_size)
    result = UnsafePointer[Scalar[DType.uint16]].alloc(1)
    runs = UnsafePointer[Scalar[DType.uint16]].alloc(1)
    memset_zero(runs.address, 1)
    memset_zero(result.address, 1)
    memset_zero(flags.address, flags_size)

    fn cycle_flags(c: SIMD[type, 1], offset: Int):
        flag = flags.load[width=1](offset)
        f = mask_f(flag)
        b = mask_b(flag)
        initial_flag = convert_flag(flag)

        if c == xmas.__getitem__(int(f)):
            f = f + 1
        else:
            f = 0
        if c == samx.__getitem__(int(b)):
            b = b + 1
        else:
            b = 0
        if f == 4:
            total_matches = result.load[width=1]() + 1
            result.store[width=1](total_matches)
            print("xmas found!")
            f = 0
        if b == 4:
            total_matches = result.load[width=1]() + 1
            result.store[width=1](total_matches)
            print("samx found!")
            b = 0
        result_flag = f | (b << 4)
        flags.store[width=1](offset, result_flag)
        runs.store[width=1](runs.load[width=1]() + 1)
        log_cycle_flags(
            runs.load[width=1](),
            c,
            initial_flag,
            convert_flag(result_flag),
            offset,
        )

    for k in range(2 * n):
        for i in range(n):
            for j in range(n):
                # offsets: straights, maindiag, skewdiag
                st = k
                md = 2 * n + k
                sd = 4 * n - 1 + k
                # current char
                item = ord(s[j * n + i])
                if i == k:
                    cycle_flags(item, st)
                if k - n == j:
                    cycle_flags(item, st)
                if k < (2 * n - 1):
                    km = k - (n - 1)
                    ks = k
                    if j - i == km:
                       cycle_flags(item, md)
                    if i + j == ks:
                       cycle_flags(item, sd)
    print(
        "\033[92mruns:\033[0m",
        runs.load[width=1](),
        "\033[92mmatches:\033[0m",
        result.load[width=1](),
        sep=" ",
    )
    flags.free()
