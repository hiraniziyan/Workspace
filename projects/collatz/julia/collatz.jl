
function col(i :: Int)
	length = 0
	num = i
	while i != 1
		if i % 2 == 0
			i ÷= 2
			if (i > num)
				num = i
			end
		else
			i = i * 3 + 1
			if (i > num)
				num = i
			end
		end
		length += 1
	end
	return num
end

function main()

	arg1 = ARGS[1]
	arg2 = ARGS[2]
	
	startStr = arg1[1:2] * arg1[4:5] * arg1[7:10]
	finishStr = arg2[1:2] * arg2[4:5] * arg2[7:10]
	start = parse(Int, startStr)
	finish = parse(Int, finishStr)
	num = 0
	for i in start : finish
		n = col(i)
		if (n > num)
			num = n	
		end	
	end

	println(num)
end

main()
