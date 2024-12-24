from python import Python

def main():
    re = Python.import_module("re")
    with open("./2024_3.input", "r") as f:
        content = f.read()
        pattern = r"mul\([0-9]{1,3},[0-9]{1,3}\)|do\(\)|don't\(\)"
        #pattern = r"mul\([0-9]{1,3},[0-9]{1,3}\)"
        matches = re.findall(pattern, content)
        acc = 0
        enabled = True
        for i in range(0, len(matches)):
          if str(matches[i]) == "do()":
            enabled = True
          elif str(matches[i]) == "don't()":
            enabled = False
          elif enabled:
            nums = (
                matches[i]
                .replace("mul", "")
                .replace("(", "")
                .replace(")", "")
                .split(",")
            )
            acc += atol(str(nums[0])) * atol(str(nums[1]))
            #print(acc, nums[0], nums[1], sep=" ")
        print(acc)
