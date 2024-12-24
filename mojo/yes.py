import sys
import os

def main():
    if len(sys.argv) == 2:
        arg = sys.argv[1]
        mode = arg if arg == "input" else "test"
        filename = "./2024_2." + mode
        hell(filename)

def jigokuraku(filename):
    try:
        with open(filename, "r") as f:
            lines = f.read().splitlines()
            for line in lines:
                print(line[0])
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")


def heaven(filename):
    try:
        with open(filename, "rb") as f:
            lines = f.read()
            i = 0
            while i < len(lines):
                n = [48, 48]  # Initialize n as a list of two integers
                offset = [48, 48]  # Initialize offset
                metric = [10, 1]  # Initialize metric
                while i < len(lines) and lines[i] != ord(' ') and lines[i] != ord('\n'):
                    n = n[1:] + [lines[i]] #Effectively shifts left by 1
                    i += 1
                if lines[i] != 10:
                    result = ((n[0] - offset[0]) * metric[0] + (n[1] - offset[1]) * metric[1])
                    print(result, end=" ")
                i += 1  # Increment i to move to the next character
            print()
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")


def hell(filename):
    try:
        with open(filename, "r") as f:
            lines = f.read().splitlines()
            safe_lines = len(lines)
            potentialy_safe_lines = 0
            for l, line in enumerate(lines):
                s = line.split(" ")
                if not check(s):
                    print(f"line {l}:")
                    safe_lines -= 1
                    potentialy_safe = false
                    for i in range(0,len(s)):
                        if s.


            print(f"There are {safe_lines} safe lines")
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except IndexError:
        print("Error: Invalid input format in the file.")


def check(s):
    def dir(a, b):
        return int(a) - int(b)

    try:
        start_dir = dir(s[0], s[1])
        is_safe = True
        for i in range(1, len(s)):
            curr_dir = dir(s[i - 1], s[i])
            if 1 <= abs(curr_dir) <= 3:
                if (curr_dir < 0 and start_dir < 0) or (curr_dir > 0 and start_dir > 0):
                    pass
                else:
                    is_safe = False
                    print(f"INFRACTION of interval  word: {i}")
            else:
                is_safe = False
                print(f"INFRACTION of size word: {i}")
        return is_safe
    except (ValueError, IndexError):
        print("Error: Invalid input format in a line.")
        return False


if __name__ == "__main__":
    main()
