
function recCol(i :: Int, currMax :: Int)
	if (i > currMax)
		currMax = i
	end
	if (i == 1)
		return currMax
	elseif (i%2 == 0)
		i ÷= 2
		return recCol(i, currMax)
	else
		i = i * 3 + 1
		return recCol(i, currMax)
	end
	
end

function main()

        arg1 = ARGS[1]
        arg2 = ARGS[2]


        start = parse(Int, arg1)
        finish = parse(Int, arg2)


        minIndex = 0
	num = 0
        for i in start : finish
                duplicate = false
                len = recCol(i, 0)
		if (len > num)
			num = len
		end

        end

        println(num)
end

main()

