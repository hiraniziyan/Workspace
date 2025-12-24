program collatz
        implicit none

        integer(kind = 8) :: bnum, i, first, last, num, p, minLen, minIndex, maxNum
        character(len = 50) :: arg1, arg2, s1, s2
        call get_command_argument(1, arg1)
        call get_command_argument(2, arg2)

        s1 = arg1(1:2) // arg1(4:5) // arg1(7:10)
        s2 = arg2(1:2) // arg2(4:5) // arg2(7:10)
        read(s1, *) first
        read(s2, *) last

        maxNum = 0
        do num = first, last
                i = num
                call col(i, bnum)
                if (bnum > maxNum) then
                        maxNum = bNum
                end if 
        end do
       
        print *, maxNum 
        

contains

subroutine col(i, bnum)
        integer(kind = 8) :: i, bnum
        bnum = i 
        do
                if (i == 1) then
                        exit
                endif

                if (mod(i,2) == 0) then
                        i = i / 2
                        if (i > bnum) then
                                bnum = i
                        end if
                else
                        i = i * 3 + 1
                        if (i > bnum) then
                                bnum = i 
                        end if
                end if

        end do
end subroutine col

end program collatz
