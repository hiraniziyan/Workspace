module card_module
    implicit none
    private
    public :: Card, initCard, printCard, rankValue, suitValue, equalsCard

    type Card
        character(2) :: rank = ""
        character(1) :: suit = ""
    contains
        procedure :: initCard
        procedure :: printCard
        procedure :: rankValue
        procedure :: suitValue
        procedure :: equalsCard
    end type Card

contains

    subroutine initCard(this, rank, suit)
        class(Card) :: this
        character(len=*) :: rank, suit
        this%rank = rank
        this%suit = suit
    end subroutine initCard

    subroutine printCard(this)
        class(Card) :: this
        print *, this%rank // this%suit
    end subroutine printCard

    function rankValue(this) result(val)
        class(Card) :: this
        integer :: val

        if (this%rank == "A ") then
            val = 14
        else if (this%rank == "K ") then
            val = 13
        else if (this%rank == "Q ") then
            val = 12
        else if (this%rank == "J ") then
            val = 11
        else
            ! help from stackoverflow for conversion
            ! https://stackoverflow.com/questions/24071722/converting-a-string-to-an-integer-in-fortran-90
            read(this%rank, *) val
        end if
    end function rankValue

    function suitValue(this) result(cardSuitValue)
        class(Card) :: this
        integer :: cardSuitValue

        if (this%suit == "D") then
            cardSuitValue = 1
        else if (this%suit == "C") then
            cardSuitValue = 2
        else if (this%suit == "H") then
            cardSuitValue = 3
        else if (this%suit == "S") then
            cardSuitValue = 4
        end if
    end function suitValue

    function equalsCard(this, other) result(isEqual)
        class(Card) :: this
        class(Card) :: other
        logical :: isEqual

        isEqual = (this%rank == other%rank) .and. (this%suit == other%suit)
    end function equalsCard
end module card_module
