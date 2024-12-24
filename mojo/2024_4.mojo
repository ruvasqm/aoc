from memory import memset_zero
from sys import simdwidthof
from algorithm.functional import vectorize
from random import rand
from sys import argv
alias type = DType.uint8
alias simd_width = simdwidthof[DType.uint8]()


struct Matrix[rows: Int, cols: Int]:
    var data: UnsafePointer[Scalar[type]]

    # Initialize zeroeing all values
    fn __init__(inout self):
        self.data = UnsafePointer[Scalar[type]].alloc(rows * cols)
        memset_zero(self.data.address, rows * cols)

    # Initialize taking a pointer, don't set any elements
    fn __init__(inout self, data: UnsafePointer[Scalar[type]]):
        self.data = data

    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    # Initialize with random values

    @staticmethod
    fn rand() -> Self:
        var data = UnsafePointer[Scalar[type]].alloc(rows * cols)
        rand(data.address, rows * cols)
        return Self(data)

    fn __getitem__(self, y: Int, x: Int) -> Scalar[type]:
        return self.load[1](y, x)

    fn __setitem__(self, y: Int, x: Int, val: Scalar[type]):
        self.store[1](y, x, val)

    fn load[nelts: Int](self, y: Int, x: Int) -> SIMD[type, nelts]:
        return self.data.load[width=nelts](y * self.cols + x)

    fn store[nelts: Int](self, y: Int, x: Int, val: SIMD[type, nelts]):
        return self.data.store[width=nelts](y * self.cols + x, val)

    fn copy(self) -> Self:
        d = Matrix[self.rows, self.cols]()
        d.store[self.cols * self.rows](
            0, 0, self.load[self.cols * self.rows](0, 0)
        )
        return d

    fn mirror_v(self) -> Self:
        for j in range(self.rows):
            r = self.load[self.cols](j, 0)
            idx = 0
            while idx <= self.cols - 1 - idx:
                tmp = r[idx]
                r[idx] = r[self.cols - 1 - idx]
                r[self.cols - 1 - idx] = tmp
                idx += 1
            self.store[self.cols](j, 0, r)
        return self

    fn shift_right(self) -> Self:
        for j in range(0, self.rows):
            r = UnsafePointer[Scalar[type]].alloc(cols)
            memset_zero(r.address, cols)
            for i in range(j + 1, self.cols):
                r.store[width=1](i, self.load[1](j, i - j))
            for i in range(0, j):
                r.store[width=1](i, ord(" "))
            self.store[self.cols](j, 0, r.load[width = self.cols]())
        return self

    fn shift_left(self) -> Self:
        for j in range(0, self.rows):
            l = UnsafePointer[Scalar[type]].alloc(cols)
            memset_zero(l.address, cols)
            for i in range(j + 1, self.cols):
                l.store[width=1](i - j, self.load[1](j, i))
            for i in range(self.cols - j, self.cols):
                l.store[width=1](i, ord(" "))
            self.store[self.cols](j, 0, l.load[width = self.cols]())
        return self

    fn check_xmas(self) -> Int:
        xmas = SIMD[type, 4](ord("X"), ord("M"), ord("A"), ord("S"))
        samx = SIMD[type, 4](ord("S"), ord("A"), ord("M"), ord("X"))
        matches = 0
        for j in range(self.rows):
            for i in range(self.cols - xmas.size + 1):
                p = self.load[nelts=4](j, i)
                if all((xmas & p) == xmas):
                    matches += 1
                if all((samx & p) == samx):
                    matches += 1
        print("found ", matches, " matches")
        return matches

    fn check_d(self) -> Int:
        dl = SIMD[type,256]()
        dr = SIMD[type,256]()
        x = self.copy().mirror_v()
        for j in range(self.rows):
            for i in range(self.cols):
                if i == j:
                    dl[i] = self.load[1](j, i)
                    dr[i] = x.load[1](j, i)
        xmas = SIMD[type, 4](ord("X"), ord("M"), ord("A"), ord("S"))
        samx = SIMD[type, 4](ord("S"), ord("A"), ord("M"), ord("X"))
        matches = 0
        for j in range(self.cols - xmas.size +1):
          if xmas[0] == dl[j] and xmas[1] == dl[j+1] and xmas[2] == dl[j+2] and xmas[3] == dl[j+3]:
            matches += 1
          if samx[0] == dl[j] and samx[1] == dl[j+1] and samx[2] == dl[j+2] and samx[3] == dl[j+3]:
            matches += 1
          if xmas[0] == dr[j] and xmas[1] == dr[j+1] and xmas[2] == dr[j+2] and xmas[3] == dr[j+3]:
            matches += 1
          if samx[0] == dr[j] and samx[1] == dr[j+1] and samx[2] == dr[j+2] and samx[3] == dr[j+3]:
            matches += 1
        print("found ", matches, " matches")
        return matches

    fn transpose(self) -> Self:
        for j in range(self.rows):
            for i in range(j, self.cols):
                a = self.load[nelts=1](j, i)
                b = self.load[nelts=1](i, j)
                self.store[nelts=1](j, i, b)
                self.store[nelts=1](i, j, a)
                # print(a != self.load[nelts=1](i, j))
                # print(b != self.load[nelts=1](j, i))
        return self

    fn show(self):
        for j in range(self.rows):
            for i in range(self.cols):
                print(chr(int(self.load[nelts=1](j, i))), end="")
            print()

    fn load_file(self, s: String):
        # print(len(s))

        @parameter
        fn closure[simd_width: Int](i: Int):
            o = SIMD[DType.uint8, simd_width]()
            for n in range(simd_width):
                o[i + n] = ord(s[i + n])
            self.data.store[width=simd_width](i, o)
            # print("storing", simd_width, "els at pos", i, end=" ")
            # print(o, end=" ")
            # print(self.data.load[width=simd_width](i))

        vectorize[closure, simd_width](len(s))


fn main() raises:
    print("starting")
    with open("./2024_4.test", "rb") as f:
        print("reading")
        s = f.read()
        print("read")
        a = Matrix[10, 10]()
        s = s.replace("\n", "").replace("\r", "")
        # print(ord(s[0]))
        a.load_file(s)
        # a.copy().shift_left().transpose().mirror_v().show()
        h = a.copy().check_xmas()
        v = a.copy().transpose().check_xmas()
        dl = a.copy().shift_left().transpose().mirror_v().check_xmas()
        dld = (
            a.copy()
            .mirror_v()
            .transpose()
            .shift_right()
            .transpose()
            .check_xmas()
        )
        dr = a.copy().shift_right().transpose().mirror_v().check_xmas()
        drd = (
            a.copy()
            .mirror_v()
            .transpose()
            .shift_left()
            .transpose()
            .check_xmas()
        )
        td = a.copy().check_d()
        print()
        # a.copy().mirror_v().transpose().shift_left().transpose().show()
        print(h + v + dl + dld + dr + drd + td)

        a.data.free()
