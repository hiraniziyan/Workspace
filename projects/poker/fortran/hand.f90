module hand_module
    use card_module
    implicit none
    private
    public :: Hand

    type Hand
        integer :: handValue = 0
        character(:), allocatable :: label
        type(Card) :: highestCard
        type(Card), allocatable :: cards(:)
        type(Card), allocatable :: originalOrder(:)
        type(Card) :: excluded
    contains
        procedure :: initHand
        procedure :: toString
        procedure :: printWithLabel
        procedure :: lessThan
        procedure :: bubbleSortCards
        procedure :: isFlush
        procedure :: isStraight
        procedure :: checkPair
        procedure :: checkThree
        procedure :: checkFour
        procedure :: checkFullHouse
        procedure :: checkTwoPair
        procedure :: findWin
    end type Hand

contains

    subroutine initHand(this, c, e)
        class(Hand) :: this
        type(Card) :: c(:)
        type(Card) :: e

        this%cards = c
        this%originalOrder = c
        this%excluded = e
        call this%findWin()
    end subroutine initHand

    subroutine toString(this)
        ! print with correct format
        class(Hand) :: this
        integer :: i

        do i = 1, size(this%originalOrder)
            ! add space manually when rank is not 10
            if (trim(this%originalOrder(i)%rank) /= "10") then
                write(*, '(A)', advance='no') ' ' // trim(this%originalOrder(i)%rank) // this%originalOrder(i)%suit // ' '
            else
                write(*, '(A)', advance='no') trim(this%originalOrder(i)%rank) // this%originalOrder(i)%suit // ' '
            end if
        end do
        
        ! add space manually when rank is not 10
        if (trim(this%excluded%rank) /= "10") then
            write(*, '(A)') '| ' // ' ' // trim(this%excluded%rank) // this%excluded%suit
        else
            write(*, '(A)') '| ' // trim(this%excluded%rank) // this%excluded%suit 
        end if

    end subroutine toString

    subroutine printWithLabel(this)
        ! print with win label
        class(Hand) :: this
        integer :: i

        do i = size(this%cards), 1, -1
            ! add space manually when rank is not 10
            if (trim(this%cards(i)%rank) /= "10") then
                write(*, '(A)', advance='no') ' ' // trim(this%cards(i)%rank) // this%cards(i)%suit // ' '
            else
                write(*, '(A)', advance='no') trim(this%cards(i)%rank) // this%cards(i)%suit // ' '
            end if
        end do
        
        ! add space manually when rank is not 10
        if (trim(this%excluded%rank) /= "10") then
            write(*, '(A)') '| ' // ' ' // trim(this%excluded%rank) // this%excluded%suit // ' -- ' // trim(this%label)
        else
            write(*, '(A)') '| ' // trim(this%excluded%rank) // this%excluded%suit // ' -- ' // trim(this%label)
        end if
    
    end subroutine printWithLabel


    function lessThan(this, other) result(resultValue)
        class(Hand) :: this, other
        logical :: resultValue
        resultValue = this%handValue < other%handValue
    end function lessThan


    subroutine bubbleSortCards(this) ! least to greatest
        class(Hand) :: this
        integer :: i, j, n
        type(Card) :: temp
        do i = 1, size(this%cards)
            do j = 1, size(this%cards) - i
                if ((this%cards(j)%rankValue() > this%cards(j+1)%rankValue()) .or. ((this%cards(j)%rankValue() == this%cards(j+1)%rankValue()) .and. (this%cards(j)%suitValue() > this%cards(j+1)%suitValue()))) then
                    temp = this%cards(j)
                    this%cards(j) = this%cards(j+1)
                    this%cards(j+1) = temp
                end if
            end do
        end do
    end subroutine bubbleSortCards


    function isFlush(this) result(resultValue)
        class(Hand) :: this
        logical :: resultValue
        integer :: i

        resultValue = .true.

        ! check if all suits are the same as the first suit
        do i = 2, size(this%cards)
            if (this%cards(i)%suit /= this%cards(1)%suit) then
                resultValue = .false.
                return
            end if
        end do

        this%label = "Flush"
        this%handValue = 6
        this%highestCard = this%cards(size(this%cards))
    end function isFlush


    function isStraight(this) result(resultValue)
        class(Hand) :: this
        logical :: resultValue
        integer :: i

        resultValue = .true.
        
        ! check for ace low straight manually
        if ((this%cards(1)%rankValue() == 2) .and. (this%cards(2)%rankValue() == 3) .and. (this%cards(3)%rankValue() == 4) .and. (this%cards(4)%rankValue() == 5) .and. (this%cards(5)%rankValue() == 14)) then
            this%label = "Straight"
            this%handValue = 5
            this%highestCard = this%cards(5)
            return
        end if

        ! check if next card's rank val is current + 1
        do i = 1, size(this%cards) - 1
            if (this%cards(i+1)%rankValue() /= this%cards(i)%rankValue() + 1) then
                resultValue = .false.
                return
            end if
        end do

        this%label = "Straight"
        this%handValue = 5
        if (this%cards(5)%rankValue() == 14) then
            this%highestCard = this%cards(4)
        else
            this%highestCard = this%cards(5)
        end if
    end function isStraight


    function checkPair(this) result(resultValue)
        class(Hand) :: this
        logical :: resultValue
        integer :: i
        resultValue = .false.

        ! check if card after is the same rank value as current card
        do i = 1, size(this%cards) - 1
            if (this%cards(i)%rankValue() == this%cards(i+1)%rankValue()) then
                this%label = "Pair"
                this%handValue = 2
                this%highestCard = this%cards(i+1)
                resultValue = .true.
                return
            end if
        end do
    end function checkPair


    function checkThree(this) result(resultValue)
        class(Hand) :: this
            logical :: resultValue

            resultValue = .false.

            ! check all three combinations manually
            if (this%cards(1)%rankValue() == this%cards(2)%rankValue() .and. this%cards(2)%rankValue() == this%cards(3)%rankValue()) then
                this%label = "Three of a Kind"
                this%handValue = 4
                this%highestCard = this%cards(3)
                resultValue = .true.
                return
            end if

            if (this%cards(2)%rankValue() == this%cards(3)%rankValue() .and. this%cards(3)%rankValue() == this%cards(4)%rankValue()) then
                this%label = "Three of a Kind"
                this%handValue = 4
                this%highestCard = this%cards(4)
                resultValue = .true.
                return
            end if

            if (this%cards(3)%rankValue() == this%cards(4)%rankValue() .and. this%cards(4)%rankValue() == this%cards(5)%rankValue()) then
                this%label = "Three of a Kind"
                this%handValue = 4
                this%highestCard = this%cards(5)
                resultValue = .true.
                return
        end if

    end function checkThree


     function checkFour(this) result(resultValue)
        class(Hand) :: this
        logical :: resultValue

        resultValue = .false.

        ! check fourofakind manualy for both combiantions
        if (this%cards(1)%rankValue() == this%cards(2)%rankValue() .and. this%cards(2)%rankValue() == this%cards(3)%rankValue() .and. this%cards(3)%rankValue() == this%cards(4)%rankValue()) then
            this%label = "Four of a Kind"
            this%handValue = 8
            this%highestCard = this%cards(5)
            resultValue = .true.
            return
        end if

        if (this%cards(2)%rankValue() == this%cards(3)%rankValue() .and. this%cards(3)%rankValue() == this%cards(4)%rankValue() .and. this%cards(4)%rankValue() == this%cards(5)%rankValue()) then
            this%label = "Four of a Kind"
            this%handValue = 8
            this%highestCard = this%cards(1)
            resultValue = .true.
            return
        end if

    end function checkFour



    function checkFullHouse(this) result(resultValue)
        class(Hand) :: this
        logical :: resultValue
        resultValue = .false.

        ! check full house manually for both combinations (1=2=3 && 4=5 || 1=2 && 3=4=5)
        if ((this%cards(1)%rankValue() == this%cards(2)%rankValue()) .and. (this%cards(2)%rankValue() == this%cards(3)%rankValue()) .and. (this%cards(4)%rankValue() == this%cards(5)%rankValue())) then
            this%label = "Full House"
            this%handValue = 7
            this%highestCard = this%cards(3)
            resultValue = .true.
            return
        end if

        if ((this%cards(1)%rankValue() == this%cards(2)%rankValue()) .and. (this%cards(3)%rankValue() == this%cards(4)%rankValue()) .and. (this%cards(4)%rankValue() == this%cards(5)%rankValue())) then
            this%label = "Full House"
            this%handValue = 7
            this%highestCard = this%cards(5)
            resultValue = .true.
        end if
    end function checkFullHouse


    function checkTwoPair(this) result(resultValue)
        class(Hand) :: this
        logical :: resultValue
        logical :: hasOnePair
        integer :: kickerCardPos, i

        hasOnePair = .false.
        kickerCardPos = -1
        resultValue = .false.
        
        i = 1
        do while (i < size(this%cards))
            if (this%cards(i)%rankValue() == this%cards(i+1)%rankValue()) then
                if (.not. hasOnePair) then
                    hasOnePair = .true.         ! one pair found
                else
                    this%label = "Two Pair"     ! second pair found
                    this%handValue = 3
                    if (kickerCardPos /= -1) then       ! make the kicket card the one not part of either pair
                        this%highestCard = this%cards(kickerCardPos + 1)
                    else
                        this%highestCard = this%cards(5)
                    end if
                    resultValue = .true.
                    return
                end if
                i = i + 2  ! skip the next card since it's part of the pair
            else
                kickerCardPos = i
                i = i + 1
            end if
        end do

    end function checkTwoPair



    subroutine findWin(this)
        class(Hand) :: this
        type(Card) :: ace
        integer :: i
        call this%bubbleSortCards()  ! sort cards for easy win type calculations

        ! check what type of win
        if (this%isStraight() .and. this%isFlush()) then
            if ((this%cards(5)%rankValue() == 14) .and. (this%cards(4)%rankValue() == 13)) then
                this%label = "Royal Straight Flush"
                this%handValue = 10
                this%highestCard = this%cards(5)
            else
                this%label = "Straight Flush"
                this%handValue = 9
                this%highestCard = this%cards(5)
            end if
           
            ! ace low (move ace to the front)
            if ((this%cards(5)%rankValue() == 14) .and. (this%cards(1)%rankValue() == 2)) then
                ace = this%cards(5)
                do i = 5, 2, -1
                    this%cards(i) = this%cards(i - 1)
                end do
                this%cards(1) = ace
            end if
            return
        end if

        if (this%checkFour()) then 
            return
        end if
        if (this%checkFullHouse()) then
            return
        end if
        if (this%isFlush()) then
            return
        end if
        if (this%isStraight()) then
            ! ace low (move ace to the front)
            if ((this%cards(5)%rankValue() == 14) .and. (this%cards(1)%rankValue() == 2)) then
                ace = this%cards(5)
                do i = 5, 2, -1
                    this%cards(i) = this%cards(i - 1)
                end do
                this%cards(1) = ace
            end if
            return
        end if
        if (this%checkThree()) then
            return
        end if
        if (this%checkTwoPair()) then
            return
        end if
        if (this%checkPair()) then
            return
        end if

        this%label = "High Card"
        this%handValue = 1
        this%highestCard = this%cards(size(this%cards))
    end subroutine findWin

end module hand_module
