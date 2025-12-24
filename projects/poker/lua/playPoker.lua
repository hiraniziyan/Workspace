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

local function printCards(hand)
    io.write(" ")
    for _, c in ipairs(hand) do
        io.write(tostring(c) .. " ")
    end
    print("\n")
end

local function printHand(h)
    for i = #h.cards, 1, -1 do
        io.write(string.format("%3s ", tostring(h.cards[i])))
    end
    io.write(" | ")
    for _, c in ipairs(h.excluded) do
        io.write(string.format("%3s ", tostring(c)))
    end
end

local function getExcluded(fullHand, fiveCardHand)
    local excluded = {}
    for _, fullCard in ipairs(fullHand) do
        local isUsed = false
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

function statDeck()
    local allCards = {
        "2S","3S","4S","5S","6S","7S","8S","9S","10S","JS","QS","KS","AS",
        "2H","3H","4H","5H","6H","7H","8H","9H","10H","JH","QH","KH","AH",
        "2C","3C","4C","5C","6C","7C","8C","9C","10C","JC","QC","KC","AC",
        "2D","3D","4D","5D","6D","7D","8D","9D","10D","JD","QD","KD","AD"
    }

    local used = {}
    local hand = {}

    while #hand < 8 do
        local idx = math.random(1, 52)
        if not used[idx] then
            used[idx] = true
            hand[#hand + 1] = Card:new(allCards[idx])
        end
    end

    return hand
end

-- fast 5-card evaluator (returns 1..10)
local function evaluateFast5(cards)
    local r1 = cards[1].rank.value
    local r2 = cards[2].rank.value
    local r3 = cards[3].rank.value
    local r4 = cards[4].rank.value
    local r5 = cards[5].rank.value

    local s1 = cards[1].suit.symbol
    local s2 = cards[2].suit.symbol
    local s3 = cards[3].suit.symbol
    local s4 = cards[4].suit.symbol
    local s5 = cards[5].suit.symbol

    local isFlush = (s1 == s2) and (s2 == s3) and (s3 == s4) and (s4 == s5)

    local counts = {}
    local function add(v)
        counts[v] = (counts[v] or 0) + 1
    end

    add(r1) add(r2) add(r3) add(r4) add(r5)

    local pairsCount, trips, quads = 0, 0, 0
    for _, c in pairs(counts) do
        if c == 2 then pairsCount = pairsCount + 1 end
        if c == 3 then trips = trips + 1 end
        if c == 4 then quads = quads + 1 end
    end

    local ranks = {r1, r2, r3, r4, r5}
    table.sort(ranks)

    local isStraight = false
    if ranks[1] == 2 and ranks[2] == 3 and ranks[3] == 4 and ranks[4] == 5 and ranks[5] == 14 then
        isStraight = true
    else
        isStraight =
            (ranks[1] + 1 == ranks[2]) and
            (ranks[2] + 1 == ranks[3]) and
            (ranks[3] + 1 == ranks[4]) and
            (ranks[4] + 1 == ranks[5])
    end

    if isStraight and isFlush then
        if ranks[5] == 14 and ranks[4] == 13 then
            return 10 -- Royal Straight Flush
        end
        return 9 -- Straight Flush
    end

    if quads == 1 then return 8 end

    if trips == 1 and pairsCount == 1 then return 7 end

    if isFlush then return 6 end

    if isStraight then return 5 end

    if trips == 1 then return 4 end

    if pairsCount == 2 then return 3 end

    if pairsCount == 1 then return 2 end

    return 1
end

local function statisticalAnalysisFast(winType)
    if winType == 1 then
        countHighCard = countHighCard + 1
    elseif winType == 2 then
        countPair = countPair + 1
    elseif winType == 3 then
        countTwoPair = countTwoPair + 1
    elseif winType == 4 then
        countThreeOfAKind = countThreeOfAKind + 1
    elseif winType == 5 then
        countStraight = countStraight + 1
    elseif winType == 6 then
        countFlush = countFlush + 1
    elseif winType == 7 then
        countFullHouse = countFullHouse + 1
    elseif winType == 8 then
        countFourOfAKind = countFourOfAKind + 1
    elseif winType == 9 then
        countStraightFlush = countStraightFlush + 1
    elseif winType == 10 then
        countRoyalStraightFlush = countRoyalStraightFlush + 1
    end
end

-- make 56 combinations out of the eight card hand
local function makeCardCombos(fullHand, useStats)
    local combos = {}
    local n = #fullHand

    for a = 1, n - 4 do
        for b = a + 1, n - 3 do
            for c = b + 1, n - 2 do
                for d = c + 1, n - 1 do
                    for e = d + 1, n do
                        local fiveCardHand = {
                            fullHand[a], fullHand[b], fullHand[c],
                            fullHand[d], fullHand[e]
                        }

                        if useStats then
                            local wt = evaluateFast5(fiveCardHand)
                            statisticalAnalysisFast(wt)
                        else
                            local excluded = getExcluded(fullHand, fiveCardHand)
                            table.insert(combos, Hand:new(fiveCardHand, excluded))
                        end
                    end
                end
            end
        end
    end

    return combos
end

local function printStats(totalHands)
    print("\n=== Statistical Analysis (" .. totalHands .. " Hands) ===\n")
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

    local swap = false
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
    elseif arg[index] == "-j" then
        useJokers = true
    elseif arg[index] == "-s" then
        local nextArg = arg[index + 1]
        local num = nextArg and tonumber(nextArg) or nil
        if num and num > 0 then
            stats = num
        else
            stats = 1
        end
        useStats = true
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
    for i = 1, stats do
	print(i)
        local eightHand = statDeck()
        makeCardCombos(eightHand, true)
    end
    printStats(stats * 56)
    os.exit()
end

local hands = makeCardCombos(fullHand, false)

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
