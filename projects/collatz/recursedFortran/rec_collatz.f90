program rec_collatz
        implicit none

        type :: colNum
                integer :: n
                integer :: len
        end type colNum

        logical :: duplicate
        type(colNum), allocatable :: arr(:)
        integer(kind = 8) :: length, i, first, last, num, p, minLen, minIndex, n, m
        character(len = 50) :: arg1, arg2
        call get_command_argument(1, arg1)
        call get_command_argument(2, arg2)

        read(arg1, *) first
        read(arg2, *) last

        allocate(arr(0))

        minLen = huge(1)
        minIndex = 0
        n = 0
        m = 0
        do num = first, last
                duplicate = .false.
                length = 0
                i = num
                length = col(i, m)
                if (length > n) then
                        n = length
                end if
                do p = 1, size(arr)
                        if (length == arr(p)%len) then
                                duplicate = .true.
                                exit
                        end if
                end do

                if (size(arr) < 10 .and. (.not. duplicate)) then
                        arr = [arr, colNum(num, length)]
                        call findMin(arr, minLen, minIndex)
                else
                        if (length > minLen .and. (.not. duplicate)) then
                                arr(minIndex) = colNum(num, length)

                                call findMin(arr, minLen, minIndex)
                        end if

                end if
        end do

        print *, n

contains

recursive function col(i, maxV) result(m)
        integer(kind = 8) :: i, maxV, newMax, m

        if (i > maxV) then
                maxV = i
                newMax = i
        else 
                newMax = maxV
        end if
        if (i == 1) then
                 m = newMax
        else if(mod(i,2) == 0) then
                i = i / 2
                m = col(i, newMax)
        else
                i = i * 3 + 1
                m = col(i, newMax)
        end if
end function col

subroutine lenSort(arr)
        type(colNum) :: arr(:)
        integer :: i, j, k
        type(colNum) :: temp

        k = size(arr)
        do i = 1, k - 1
                do j = 1, k - i
                        if (arr(j)%len < arr(j+1)%len) then
                                temp = arr(j)
                                arr(j) = arr(j+1)
                                arr(j+1) = temp
                        end if
                end do
        end do
end subroutine lenSort

subroutine numSort(arr)
        type(colNum) :: arr(:)
        integer :: i, j, k
        type(colNum) :: temp

        k = size(arr)
        do i = 1, k - 1
                do j = 1, k - i
                        if (arr(j)%n < arr(j+1)%n) then
                                temp = arr(j)
                                arr(j) = arr(j+1)
                                arr(j+1) = temp
                        end if
                end do
        end do
end subroutine numSort

subroutine findMin(arr, minLen, minIndex)
        type(colNum) :: arr(:)
        integer(kind=8) :: minLen, minIndex, i
        minLen = arr(1)%len
        minIndex = 1
        do i = 2, size(arr)
                if (arr(i)%len < minLen) then
                        minLen = arr(i)%len
                        minIndex = i
                end if
        end do
end subroutine findMin


end program rec_collatz
