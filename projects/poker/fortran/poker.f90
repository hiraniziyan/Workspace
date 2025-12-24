program poker
    use card_module
    use hand_module
    implicit none

    type(Card), allocatable :: sixHand(:)
    type(Hand), allocatable :: hands(:)
    integer :: argc
    character(300) :: filename

    argc = command_argument_count()

    print *, ""
    print *, "*** P O K E R  H A N D  A N A L Y Z E R ***"
    print *, ""
    print *, ""

    if (argc == 0) then
        print *, "*** USING RANDOMIZED DECK OF CARDS ***"
        call generateDeck(sixHand)  ! get six card hand
    else
        
        call get_command_argument(1, filename)
        print *, "*** USING TEST DECK ***"
        print *, ""
        print *, "*** File: ", trim(filename)
        call processFile(trim(filename), sixHand)       ! get six card hand
    end if

    if (argc == 0) then
        print *, "*** Here is the hand"
        call printHand(sixHand)
    end if

    call generateCombinations(sixHand, hands)
    call printWin(hands)

contains

subroutine generateDeck(hand)
    type(Card), allocatable :: hand(:)
    type(Card) :: shuffled(52)
    character(2), dimension(13) :: ranks = (/ "A ","2 ","3 ","4 ","5 ","6 ","7 ","8 ","9 ","10","J ","Q ","K " /)
    character(1), dimension(4)  :: suits = (/ "D","C","H","S" /)
    type(Card), allocatable :: deck(:)
    integer :: i, j, k, pos
    real :: r
   
    ! allocate 52 spaces of memory 
    allocate(deck(52))
    k = 0
    do i = 1, 4
        do j = 1, 13
            k = k + 1
            call deck(k)%initCard(trim(ranks(j)), suits(i))
        end do
    end do

    call RANDOM_SEED()
    do i = 1, 52
        call RANDOM_NUMBER(r)
        pos = int(r * 52.0) + 1
        if (pos > 52) then
            pos = 52
        end if

        ! find next available position 
        do while (shuffled(pos)%rank /= '')  
            pos = mod(pos, 52) + 1
        end do

        shuffled(pos) = deck(i)
    end do


    print *, ""
    print *, "*** Shuffled 52 card deck:"
    do i = 1, 52
        write(*,'(A)', advance='no') trim(shuffled(i)%rank)//trim(shuffled(i)%suit)//' '
        if (mod(i,13)==0) then 
            print *
        end if
    end do
    print *

    hand = shuffled(1:6)
end subroutine generateDeck

subroutine printHand(cards)
    type(Card) :: cards(:)
    integer :: i
    ! print six card hand
    write(*,'(A)', advance='no') " "
    do i=1,size(cards)
        write(*,'(A)',advance='no') trim(cards(i)%rank)//trim(cards(i)%suit)//" "
    end do
    print *
    print *
end subroutine printHand

subroutine processFile(path, hand)
    character(len=*) :: path
    type(Card), allocatable :: hand(:)
    integer :: ios, i, j, n
    character(80) :: line
    character(3) :: rank
    character(1) :: suit
    character(len=:), allocatable :: token
    integer :: lineIndex, comma
    logical :: duplicate
    type(Card) :: duplicateCard
    type(Card), allocatable :: tmp(:)

    ! open and read file
    open(unit=5, file=path, status="old")
    read(5, "(A)") line
    close(5)

    print *, trim(line)
    print *

    lineIndex = 1
    do
        ! go through the line looking taking sbstrings based on the indexes of the commas
        comma = index(line(lineIndex:), ',')
        if (comma > 0) then
            token = adjustl(trim(line(lineIndex:lineIndex+comma-2)))
            lineIndex = lineIndex + comma
        else
            token = adjustl(trim(line(lineIndex:)))
            lineIndex = len_trim(line) + 1
        end if

        if (len(trim(token)) == 3) then  ! case for 10
            rank = trim(token(1:2))
            suit = trim(token(3:3))
        else
            rank = trim(token(1:1))
            suit = trim(token(2:2))
        end if

        ! add card to the array
        n = size(tmp)
        tmp = [tmp, Card(rank, suit)]  

        if (lineIndex > len(trim(line))) then
            exit
        end if
    end do

    ! Check for duplicates
    duplicate = .false.
    do i = 1, size(tmp)
        do j = i + 1, size(tmp)
            if (tmp(i)%equalsCard(tmp(j))) then
                duplicate = .true.
                duplicateCard = tmp(i)
            end if
        end do
    end do

    if (duplicate) then
        print *, "*** ERROR - DUPLICATED CARD FOUND ***"
        print *, "*** DUPLICATE: ", trim(duplicateCard%rank)//trim(duplicateCard%suit)
        stop 1
    end if

    hand = tmp
end subroutine processFile

subroutine generateCombinations(sixCards, hands)
    implicit none
    type(Card) :: sixCards(:)
    type(Hand), allocatable :: hands(:)
    integer :: i, j, n
    integer :: cardIndexTracker, excludedIndex, index
    type(Card), allocatable :: newHand(:)

    allocate(hands(size(sixCards)))
    cardIndexTracker = 0
    excludedIndex = 0

    do i = 1, size(sixCards)
        allocate(newHand(size(sixCards) - 1))

        do j = 1, size(sixCards) - 1
            index = mod(cardIndexTracker, size(sixCards)) + 1   
            cardIndexTracker = cardIndexTracker + 1
            newHand(j) = sixCards(index)
            excludedIndex = mod(index, size(sixCards)) + 1      ! next card is excluded
        end do

        call hands(i)%initHand(newHand, sixCards(excludedIndex))
        deallocate(newHand)
    end do

    ! print the combinations
    print *, "*** Hand Combinations..."
    do i = 1, 6
        call hands(i)%toString()
    end do
    print *

end subroutine generateCombinations

subroutine printWin(hands)
    type(Hand) :: hands(:)
    integer :: i
    call sortHands(hands) ! sort Hands to print in order
    print *, "--- HIGH HAND ORDER ---"
    do i=1,size(hands)
        call hands(i)%printWithLabel()
    end do
    print *
end subroutine printWin

function highCardTieBreaker(h1, h2) result(result_value)
    type(Hand) :: h1, h2
    logical :: result_value
    integer :: i

    ! check rank val first
    do i = size(h1%cards), 1, -1
        if (h1%cards(i)%rankValue() > h2%cards(i)%rankValue()) then
            result_value = .false.
            return
        else if (h1%cards(i)%rankValue() < h2%cards(i)%rankValue()) then
            result_value = .true.
            return
        else ! compare by suits if ranks are the same
            if (h1%cards(i)%suitValue() > h2%cards(i)%suitValue()) then
                result_value = .false.
                return
            else if (h1%cards(i)%suitValue() < h2%cards(i)%suitValue()) then
                result_value = .true.
                return
            end if
        end if
    end do

    result_value = .false.
end function highCardTieBreaker

function pairTieBreaker(h1, h2) result(result_value)
    type(Hand) :: h1, h2
    logical :: result_value
    type(Card), allocatable :: pair1(:), pair2(:), other1(:), other2(:)
    integer :: i

    ! add the pairs to the pair array and the cards not part of the pair to the other
    do i = 1, size(h1%cards)
        if (h1%cards(i)%rankValue() == h1%highestCard%rankValue()) then
            pair1 = [pair1, h1%cards(i)]
        else
            other1 = [other1, h1%cards(i)]
        end if
    end do

    do i = 1, size(h2%cards)
        if (h2%cards(i)%rankValue() == h2%highestCard%rankValue()) then
            pair2 = [pair2, h2%cards(i)]
        else
            other2 = [other2, h2%cards(i)]
        end if
    end do

    ! compare pair array first: rank then suits
    do i = size(pair1), 1, -1
        if (pair1(i)%rankValue() > pair2(i)%rankValue()) then
            result_value = .false.
            return
        else if (pair1(i)%rankValue() < pair2(i)%rankValue()) then
            result_value = .true.
            return
        else
            if (pair1(i)%suitValue() > pair2(i)%suitValue()) then
                result_value = .false.
                return
            else if (pair1(i)%suitValue() < pair2(i)%suitValue()) then
                result_value = .true.
                return
            end if
        end if
    end do

    ! compare other array: rank then suits
    do i = size(other1), 1, -1
        if (other1(i)%rankValue() > other2(i)%rankValue()) then
            result_value = .false.
            return
        else if (other1(i)%rankValue() < other2(i)%rankValue()) then
            result_value = .true.
            return
        else
            if (other1(i)%suitValue() > other2(i)%suitValue()) then
                result_value = .false.
                return
            else if (other1(i)%suitValue() < other2(i)%suitValue()) then
                result_value = .true.
                return
            end if
        end if
    end do

    result_value = .false.
end function pairTieBreaker

function threeTieBreaker(h1, h2) result(result_value)
    type(Hand) :: h1, h2
    logical :: result_value
    type(Card), allocatable :: trip1(:), trip2(:), other1(:), other2(:)
    integer :: i

    ! add the three of a kind to trip array and other cards to other array
    do i = 1, size(h1%cards)
        if (h1%cards(i)%rankValue() == h1%highestCard%rankValue()) then
            trip1 = [trip1, h1%cards(i)]
        else
            other1 = [other1, h1%cards(i)]
        end if
    end do

    do i = 1, size(h2%cards)
        if (h2%cards(i)%rankValue() == h2%highestCard%rankValue()) then
            trip2 = [trip2, h2%cards(i)]
        else
            other2 = [other2, h2%cards(i)]
        end if
    end do

    ! compare trip array first : rank then suits
    do i = size(trip1), 1, -1
        if (trip1(i)%rankValue() > trip2(i)%rankValue()) then
            result_value = .false.
            return
        else if (trip1(i)%rankValue() < trip2(i)%rankValue()) then
            result_value = .true.
            return
        else
            if (trip1(i)%suitValue() > trip2(i)%suitValue()) then
                result_value = .false.
                return
            else if (trip1(i)%suitValue() < trip2(i)%suitValue()) then
                result_value = .true.
                return
            end if
        end if
    end do

    ! compare other array next: rank then suits
    do i = size(other1), 1, -1
        if (other1(i)%rankValue() > other2(i)%rankValue()) then
            result_value = .false.
            return
        else if (other1(i)%rankValue() < other2(i)%rankValue()) then
            result_value = .true.
            return
        else
            if (other1(i)%suitValue() > other2(i)%suitValue()) then
                result_value = .false.
                return
            else if (other1(i)%suitValue() < other2(i)%suitValue()) then
                result_value = .true.
                return
            end if
        end if
    end do

    result_value = .false.
end function threeTieBreaker

function fourTieBreaker(h1, h2) result(result_value)
    type(Hand) :: h1, h2
    logical :: result_value

    ! compare the card not part of the four (stored as highest card) bc it is the only one different
    if (h1%highestCard%rankValue() > h2%highestCard%rankValue()) then
        result_value = .false.
        return
    else if (h1%highestCard%rankValue() < h2%highestCard%rankValue()) then
        result_value = .true.
        return
    else
        result_value = (h1%highestCard%suitValue() < h2%highestCard%suitValue())
        return
    end if
end function fourTieBreaker

function twoPairTieBreaker(h1, h2) result(result_value)
    type(Hand) :: h1, h2
    logical :: result_value
    type(Card), allocatable :: pairs1(:), pairs2(:)
    integer :: i

    ! (the kicker card has been stored as highest card for two pair)
    pairs1 = [h1%highestCard] ! // add the kicker card in the first array pos bc it contains the least importance
    pairs2 = [h2%highestCard]

    ! add the pairs to the list
    do i = 1, size(h1%cards)
        if (.not. (h1%cards(i)%equalsCard(h1%highestCard))) then
            pairs1 = [pairs1, h1%cards(i)]
        end if
        if (.not. (h2%cards(i)%equalsCard(h2%highestCard))) then 
            pairs2 = [pairs2, h2%cards(i)]
        end if
    end do

    ! compare the cards: rank then suit
    do i = size(pairs1), 1, -1
        if (pairs1(i)%rankValue() > pairs2(i)%rankValue()) then
            result_value = .false.
            return
        else if (pairs1(i)%rankValue() < pairs2(i)%rankValue()) then
            result_value = .true.
            return
        else
            if (pairs1(i)%suitValue() > pairs2(i)%suitValue()) then
                result_value = .false.
                return
            else if (pairs1(i)%suitValue() < pairs2(i)%suitValue()) then
                result_value = .true.
                return
            end if
        end if
    end do

    result_value = .false.
end function twoPairTieBreaker

function straightTieBreaker(h1, h2) result(result_value)
    ! same as highCardTieBreaker bc straights will only differ in their highest card
    type(Hand) :: h1, h2
    logical :: result_value

    result_value = highCardTieBreaker(h1, h2)
end function straightTieBreaker

function straightFlushTieBreaker(h1, h2) result(result_value)
    ! same as highCardTieBreaker bc straights will only differ in their highest card
    type(Hand) :: h1, h2
    logical :: result_value

    result_value = highCardTieBreaker(h1, h2)
end function straightFlushTieBreaker

function flushTieBreaker(h1, h2) result(result_value)
    ! same as highCardTieBreaker bc a six card hand can not produce two flushes of different suits
    type(Hand) :: h1, h2
    logical :: result_value

    result_value = highCardTieBreaker(h1, h2)
end function flushTieBreaker

function fullHouseTieBreaker(h1, h2) result(result_value)
    ! same as three tieBreaker where you compare the three of a kind then the others (pairs in this case)
    type(Hand) :: h1, h2
    logical :: result_value

    result_value = threeTieBreaker(h1, h2)
end function fullHouseTieBreaker

subroutine sortHands(hands)
    type(Hand) :: hands(:)
    integer :: i
    logical :: swapped, needSwap
    type(Hand) :: tmp
    
    ! bubble sort hands
    do
        swapped = .false.
        do i = 1, size(hands) - 1
            ! sort based on hand value first
            if (hands(i)%handValue < hands(i+1)%handValue) then
                tmp = hands(i)
                hands(i) = hands(i+1)
                hands(i+1) = tmp
                swapped = .true.
            else if (hands(i)%handValue == hands(i+1)%handValue) then ! sort by tiebreakers
                needSwap = .false.
                if (hands(i)%label == "High Card" .and. hands(i+1)%label == "High Card") then
                    needSwap = highCardTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Pair" .and. hands(i+1)%label == "Pair") then
                    needSwap = pairTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Four of a Kind" .and. hands(i+1)%label == "Four of a Kind") then
                    needSwap = fourTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Three of a Kind" .and. hands(i+1)%label == "Three of a Kind") then
                    needSwap = threeTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Full House" .and. hands(i+1)%label == "Full House") then
                    needSwap = fullHouseTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Straight Flush" .and. hands(i+1)%label == "Straight Flush") then
                    needSwap = straightFlushTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Flush" .and. hands(i+1)%label == "Flush") then
                    needSwap = flushTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Straight" .and. hands(i+1)%label == "Straight") then
                    needSwap = straightTieBreaker(hands(i), hands(i+1))
                else if (hands(i)%label == "Two Pair" .and. hands(i+1)%label == "Two Pair") then
                    needSwap = twoPairTieBreaker(hands(i), hands(i+1))
                end if

                ! perform swap
                if (needSwap) then
                    tmp = hands(i)
                    hands(i) = hands(i+1)
                    hands(i+1) = tmp
                    swapped = .true.
                end if
            end if
        end do
        if (.not. swapped) then
            exit
        end if
    end do
end subroutine sortHands

end program poker
