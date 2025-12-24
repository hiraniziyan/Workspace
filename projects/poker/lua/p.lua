local Card = require("Card")
local Hand = require("Hand")
local Deck = require("deck")
local Tiebreak = require("TieBreak")

local countHighCard            = 0
local countPair                = 0
local countTwoPair             = 0
local countThreeOfAKind        = 0
local countStraight            = 0
local countFlush               = 0
local countFullHouse           = 0
local countFourOfAKind         = 0
local countStraightFlush       = 0
local countRoyalStraightFlush  = 0

-- print the given eight cards
local function printCards(hand)
    io.write(" ")
    for _, c in ipairs(hand) do
        io.write(tostring(c) .. " ")
    end
    print("\n")
end

-- print a hand
local function printHand(h)
    for i = #h.cards, 1, -1 do
        io.write(string.format("%3s ", tostring(h.cards[i])))
    end
    io.write(" | ")
    for _, c in ipairs(h.excluded) do
        io.write(string.format("%3s ", tostring(c)))
    end
end

-- get the excluded cards
local function getExcluded(fullHand, fiveCardHand)
    local excluded = {}

    for _, fullCard in ipairs(fullHand) do
        local isUsed = false

        -- Check if fullCard appears in the 5-card hand
        for _, usedCard in ipairs(fiveCardHand) do
            if fullCard:equals(usedCard) then
                isUsed = true
                break
            end
        end

        if not isUsed then
            table.insert(excluded, fullCard)
        end
    end

    return excluded
end

-- make 56 combinations out of the eigth card hand
local function makeCardCombos(fullHand)
    local combos = {} -- store all the 56 combnations
    local n = #fullHand  -- should always be 8

    -- calculate every pair of indexes
    for a = 1, n - 4 do
        for b = a + 1, n - 3 do
            for c = b + 1, n - 2 do
                for d = c + 1, n - 1 do
                    for e = d + 1, n do

                        local fiveCardHand = {	-- make the hand using the 5 indexes
                            fullHand[a], fullHand[b], fullHand[c], fullHand[d], fullHand[e]	
                        }
			
			statisticalAnalysis(fiveCardHand)

                        local excluded = getExcluded(fullHand, fiveCardHand) -- get the excluded hand

                        table.insert(combos, Hand:new(fiveCardHand, excluded)) -- insert the hand into combos
                    end
                end
            end
        end
    end

    return combos
end

local function statisticalAnalysis(h)
        local wt = h.winType

        if wt == "High Card" then
            countHighCard = countHighCard + 1
        elseif wt == "Pair" then
            countPair = countPair + 1
        elseif wt == "Two Pair" then
            countTwoPair = countTwoPair + 1
        elseif wt == "Three of a Kind" then
            countThreeOfAKind = countThreeOfAKind + 1
        elseif wt == "Straight" then
            countStraight = countStraight + 1
        elseif wt == "Flush" then
            countFlush = countFlush + 1
        elseif wt == "Full House" then
            countFullHouse = countFullHouse + 1
        elseif wt == "Four of a Kind" then
            countFourOfAKind = countFourOfAKind + 1
        elseif wt == "Straight Flush" then
            countStraightFlush = countStraightFlush + 1
        elseif wt == "Royal Straight Flush" then
            countRoyalStraightFlush = countRoyalStraightFlush + 1
        end
end

local function printStats()
    print("\n=== Statistical Analysis (56 Combinations) ===\n")
    print("High Card             :", countHighCard)
    print("Pair                  :", countPair)
    print("Two Pair              :", countTwoPair)
    print("Three of a Kind       :", countThreeOfAKind)
    print("Straight              :", countStraight)
    print("Flush                 :", countFlush)
    print("Full House            :", countFullHouse)
    print("Four of a Kind        :", countFourOfAKind)
    print("Straight Flush        :", countStraightFlush)
    print("Royal Straight Flush  :", countRoyalStraightFlush)
end

local function compareHands(hand1, hand2)
    local swap = false

    local h1sc = hand1.winType
    local h2sc = hand2.winType

    local sc1, sc2 = 0, 0

    if h1sc == "High Card" then
        sc1 = 1
    elseif h1sc == "Pair" then
        sc1 = 2
    elseif h1sc == "Two Pair" then
        sc1 = 3
    elseif h1sc == "Three of a Kind" then
        sc1 = 4
    elseif h1sc == "Straight" then
        sc1 = 5
    elseif h1sc == "Flush" then
        sc1 = 6
    elseif h1sc == "Full House" then
        sc1 = 7
    elseif h1sc == "Four of a Kind" then
        sc1 = 8
    elseif h1sc == "Straight Flush" then
        sc1 = 9
    elseif h1sc == "Royal Straight Flush" then
        sc1 = 10
    end

    if h2sc == "High Card" then
        sc2 = 1
    elseif h2sc == "Pair" then
        sc2 = 2
    elseif h2sc == "Two Pair" then
        sc2 = 3
    elseif h2sc == "Three of a Kind" then
        sc2 = 4
    elseif h2sc == "Straight" then
        sc2 = 5
    elseif h2sc == "Flush" then
        sc2 = 6
    elseif h2sc == "Full House" then
        sc2 = 7
    elseif h2sc == "Four of a Kind" then
        sc2 = 8
    elseif h2sc == "Straight Flush" then
        sc2 = 9
    elseif h2sc == "Royal Straight Flush" then
        sc2 = 10
    end

    if sc1 ~= sc2 then
        return sc1 < sc2    
    end

    if h1sc == "High Card" then
        swap = Tiebreak.highCardTB(hand1, hand2)
    elseif h1sc == "Pair" then
        swap = Tiebreak.pairTB(hand1, hand2)
    elseif h1sc == "Two Pair" then
        swap = Tiebreak.twoPairTB(hand1, hand2)
    elseif h1sc == "Three of a Kind" then
        swap = Tiebreak.threeTB(hand1, hand2)
    elseif h1sc == "Straight" then
        swap = Tiebreak.straightTB(hand1, hand2)
    elseif h1sc == "Flush" then
        swap = Tiebreak.flushTB(hand1, hand2)
    elseif h1sc == "Full House" then
        swap = Tiebreak.fullHouseTB(hand1, hand2)
    elseif h1sc == "Four of a Kind" then
        swap = Tiebreak.fourTB(hand1, hand2)
    elseif h1sc == "Straight Flush" 
        or h1sc == "Royal Straight Flush" then
        swap = Tiebreak.straightFlushTB(hand1, hand2)
    end

    return swap
end


local function sortHands(hands)
    local swap = true
    while swap do
        swap = false
        for i = 1, #hands - 1 do
            if compareHands(hands[i], hands[i+1]) then
                hands[i], hands[i+1] = hands[i+1], hands[i]
                swap = true
            end
        end
    end
end

local useJokers = false
local useStats = false
local filename = nil
local stats = 1

for index = 1, #arg do
    if arg[index] == "-f" then
        filename = arg[index + 1]
    end

    if arg[index] == "-j" then
        useJokers = true
    end
    if arg[index] == "-s" then
        if not arg[index + 1] then
            stats = 1
        else
            stats = tonumber(arg[index + 1])
	    useStats = true
        end
    end

end


print("\n*** P O K E R   H A N D   A N A L Y Z E R ***\n\n")

local fullHand

if filename then
    print("*** USING TEST DECK ***\n")
    print("*** File: " .. filename)

    local file = io.open(filename, "r")
    local line = file:read("*l")
    file:close()

    print(line)

    fullHand = {}
    for token in string.gmatch(line, "[^,]+") do
        token = token:match("%S+")
        table.insert(fullHand, Card:new(token))
    end
elseif not useStats then
    print("*** USING RANDOMIZED DECK OF CARDS ***")
    local deckObj

    if useJokers then
        deckObj = Deck.joker()     
    else
        deckObj = Deck.new()   
    end

    deckObj:printDeck()

    fullHand = {}
    for i = 1, 8 do
        table.insert(fullHand, deckObj.deck[i])
    end

    print("*** Here is the hand")
    printCards(fullHand)
else
   for j = 1, stats do
	print(j)
   	local deckObj

    	if useJokers then
        	deckObj = Deck.joker()
    	else
        	deckObj = Deck.new()
    	end
    	fullHand = {}
    	for i = 1, 8 do
        	table.insert(fullHand, deckObj.deck[i])
    	end
	local statHands = makeCardCombos(fullHand)
    end
    printStats()
    os.exit()
	
end

local hands = makeCardCombos(fullHand)

print("\n*** Hand Combinations ***\n")
for _, h in ipairs(hands) do
    printHand(h)
    print()
end

sortHands(hands)

print("\n--- HIGH HAND ORDER ---\n")
for _, h in ipairs(hands) do
    printHand(h)
    io.write(string.format("-- %s\n", h.winType))
end
print()
