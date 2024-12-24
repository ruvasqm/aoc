from sys import simdwidthof
from algorithm.functional import vectorize

# The amount of elements to loop through
alias size = 10
# How many Dtype.int32 elements fit into the SIMD register (4 on 128bit)
alias simd_width = simdwidthof[DType.int32]()


fn main() raises:
    with open("./2024_3.input", "r") as f:
        # @parameter allows the closure to capture the `p` pointer
        bytes = f.read_bytes()
        var p = UnsafePointer[UInt8].alloc(bytes.size)

        @parameter
        fn closure[simd_width: Int](i: Int):
            o = SIMD[DType.uint8,simd_width]()
            o[0] = bytes[i]
            o[1] = bytes[i+1]
            o[2] = bytes[i+2]
            o[3] = bytes[i+3]
            o[4] = bytes[i+4]
            o[5] = bytes[i+5]
            o[6] = bytes[i+6]
            o[7] = bytes[i+7]
            p.store[width=simd_width](i, o)
            print("storing", simd_width, "els at pos", i, end=" ")
            print(o, end=" ")
            a = p.load[width=simd_width](i)
            print(p.load[width=simd_width](i))

        vectorize[closure, simd_width](bytes.size - simd_width + 1)
        """
        for i in range(0, bytes.size):
            x = p.load[width=1](i)
            b = bytes[i]
            print("simd:", x, "byte:", b, sep=" ")
        """
        p.free()
