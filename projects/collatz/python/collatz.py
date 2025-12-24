import sys

def col(i):
    num = i
    while i != 1:
        if i % 2 == 0:
            i //= 2
            if i > num:     
                num = i
        else:
            i = i * 3 + 1
            if i > num:
                num = i
    return num


def main():

    arg1 = sys.argv[1]
    arg2 = sys.argv[2]

    startStr = arg1.replace("/","")
    finishStr = arg2.replace("/","")
    start = int(startStr)
    finish = int(finishStr)
    
    

    num = 0
    for i in range(start, finish + 1):
        n = col(i)
        if n > num:
            num = n 
         
    print(num)


if __name__ == "__main__":
    main()

