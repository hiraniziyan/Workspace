struct colNum
	n :: Int
	len :: Int
end

function col(i :: Int)
	length = i
	while i != 1
		if i % 2 == 0
			i ÷= 2
		else
			i = i * 3 + 1
		end
		if i > length
			length = i
		end
	end
	return length
end

function findMinIndex(arr::Vector{colNum})
	minLen = arr[1].len
	minIndex = 1
	for i in 2:length(arr)
		if (arr[i].len < minLen)
			minLen = arr[i].len
			minIndex = i
		end
	end
	return minIndex
end

function lenSort!(arr::Vector{colNum})
	k = length(arr)
	for i in 1:(k - 1)
		for j in 1:(k - i)
			if (arr[j].len < arr[j+1].len)
				arr[j], arr[j+1] = arr[j+1], arr[j]
			end
		end
	end
end

function numSort!(arr::Vector{colNum})
	k = length(arr)
        for i in 1:(k - 1)
                for j in 1:(k - i)
                        if (arr[j].n < arr[j+1].n)
                                arr[j], arr[j+1] = arr[j+1], arr[j]
                        end
                end
        end
end

function main()

	arg1 = ARGS[1]
	arg2 = ARGS[2]

	s1 = arg1[1:2] * arg1[4:5] * arg1[7:10]
	s2 = arg2[1:2] * arg2[4:5] * arg2[7:10]
	
	println(s1)
	start = parse(Int, s1)
	finish = parse(Int, s2)

	arr = colNum[]

	minLen = typemax(Int)
	minIndex = 0
	
	for i in start : finish
		duplicate = false
		len = col(i)
		for j in 1:length(arr)
			if (len == arr[j].len)
				duplicate = true
				break
			end
		end

		if (length(arr) < 10 && (!duplicate))
			push!(arr, colNum(i, len))	
			minIndex = findMinIndex(arr) 
		elseif (len > arr[minIndex].len && (!duplicate))
			arr[minIndex] = colNum(i, len)
			minIndex = findMinIndex(arr)		
		end
	end

	lenSort!(arr)
	println("Sorted based on sequence length")
	for collatzNum in arr
		println("$(lpad(collatzNum.n, 20))$(lpad(collatzNum.len, 20))")
	end
	println(arr[1].len)
	numSort!(arr)
	println("Sorted based on integer size")
	for collatzNum in arr
		println("$(lpad(collatzNum.n, 20))$(lpad(collatzNum.len, 20))")
	end
end

main()
