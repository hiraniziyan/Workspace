import sys

class colNum:
    def __init__(self, n, length):
        self.n = n
        self.len = length


def col(i):
    length = 0
    while i != 1:
        if i % 2 == 0:
            i //= 2
        else:
            i = i * 3 + 1
        length += 1
    return length


def findMinIndex(arr):
    minLen = arr[0].len
    minIndex = 0
    for i in range(1, len(arr)):
        if arr[i].len < minLen:
            minLen = arr[i].len
            minIndex = i
    return minIndex


def lenSort(arr):
    k = len(arr)
    for i in range(k - 1):
        for j in range(k - 1 - i):
            if arr[j].len < arr[j + 1].len:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]


def numSort(arr):
    k = len(arr)
    for i in range(k - 1):
        for j in range(k - 1 - i):
            if arr[j].n < arr[j + 1].n:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]


def main():
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]

    start = int(arg1)
    finish = int(arg2)

    arr = []
    minIndex = 0
    minLen = 2**63 - 1

    for i in range(start, finish + 1):
        duplicate = False
        length = col(i)

        for item in arr:
            if item.len == length:
                duplicate = True
                break

        if len(arr) < 10 and not duplicate:
            arr.append(colNum(i, length))
            minIndex = findMinIndex(arr)
        elif not duplicate and length > arr[minIndex].len:
            arr[minIndex] = colNum(i, length)
            minIndex = findMinIndex(arr)

    lenSort(arr)
    print("Sorted based on sequence length")
    for item in arr:
        print(f"{str(item.n).rjust(20)}{str(item.len).rjust(20)}")

    numSort(arr)
    print("Sorted based on integer size")
    for item in arr:
        print(f"{str(item.n).rjust(20)}{str(item.len).rjust(20)}")


if __name__ == "__main__":
    main()

