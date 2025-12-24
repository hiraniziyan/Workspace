program collatz
        implicit none

        type :: colNum
                integer(kind = 8) :: n
                integer(kind = 8) :: len
        end type colNum

        logical :: duplicate
        type(colNum), allocatable :: arr(:)
        integer(kind = 8) :: length, i, first, last, num, p, minLen, minIndex
        character(len = 50) :: arg1, arg2
        call get_command_argument(1, arg1)
        call get_command_argument(2, arg2)

        read(arg1, *) first
        read(arg2, *) last

        allocate(arr(0))

        minLen = huge(1)
        minIndex = 0

        do num = first, last
                duplicate = .false.
                length = 0
                i = num
                call col(i, length)
                do p = 1, size(arr)
                        if (num == arr(p)%n) then
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

        call lenSort(arr)
        print *, "Sorted based on sequence length"
        do i = 1, size(arr)
                print "(I21,1X,I21)", arr(i)%n, arr(i)%len
        end do
        print *, arr(1)%len

        call numSort(arr)
        print *, "Sorted based on integer size"
        do i = 1, size(arr)
                print "(I21,1X,I21)", arr(i)%n, arr(i)%len
        end do

contains

subroutine col(i, length)
        integer(kind = 8) :: i, length
        length = i
        do
                if (i == 1) then
                        exit
                endif

                if (mod(i,2) == 0) then
                        i = i / 2
                        if (i > length) then
                                length = i
                        end if
                        
                else
                        i = i * 3 + 1
                        if (i > length) then
                                length = i
                        end if
                end if

        end do
end subroutine col

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


end program collatz
