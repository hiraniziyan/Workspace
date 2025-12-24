local Card = require("Card")
local Hand = require("Hand")
local Deck = require("deck")
local Tiebreak = require("TieBreak")

-- Statistical counters for all evaluated 5-card hands
local statsCount = {
    ["High Card"] = 0,
    ["Pair"] = 0,
    ["Two Pair"] = 0,
    ["Three of a Kind"] = 0,
    ["Straight"] = 0,
    ["Flush"] = 0,
    ["Full House"] = 0,
    ["Four of a Kind"] = 0,
    ["Straight Flush"] = 0,
    ["Royal Straight Flush"] = 0
}

---------------------------------------------------------------------
-- Utility printing
---------------------------------------------------------------------
local function printHandRaw(hand)
    io.write(" ")
    for _, c in ipairs(hand) do
        io.write(tostring(c) .. " ")
    end
    print("\n")
end

---------------------------------------------------------------------
-- Parse command-line flags
---------------------------------------------------------------------
local useJokers = false
local filename = nil
local stats = 100

for i = 1, #arg do
    if arg[i] == "-f" then
        filename = arg[i + 1]
    elseif arg[i] == "-j" then
        useJokers = true
    elseif arg[i] == "-s" then
        stats = tonumber(arg[i + 1]) or 100
    end
end

---------------------------------------------------------------------
print("\n*** P O K E R   H A N D   A N A L Y Z E R ***\n\n")
---------------------------------------------------------------------

local fullHand = nil

---------------------------------------------------------------------
-- 1. Read from file OR deal from deck
---------------------------------------------------------------------

if filename then
    print("*** USING TEST DECK ***\n")
    print("*** File: " .. filename)

    local file, err = io.open(filename, "r")
    if not file then
        print("Error opening file: " .. err)
        os.exit(1)
    end

    local line = file:read("*l")
    file:close()

    print(line)

    fullHand = {}
    for token in string.gmatch(line, "[^,]+") do
        token = token:match("%S+")
        table.insert(fullHand, Card:new(token))
    end

else
    print("*** USING RANDOMIZED DECK OF CARDS ***")

    local deckObj = useJokers and Deck.joker() or Deck.new()
    deckObj:printDeck()

    fullHand = {}
    for i = 1, 8 do
        table.insert(fullHand, deckObj.deck[i])
    end

    print("*** Here is the hand")
    printHandRaw(fullHand)
end

---------------------------------------------------------------------
-- 2. Generate ALL 56 five-card combinations of 8 cards
---------------------------------------------------------------------
local function makeCardCombos(cards)
    local combos = {}
    local n = #cards

    for a = 1, n - 4 do
        for b = a + 1, n - 3 do
            for c = b + 1, n - 2 do
                for d = c + 1, n - 1 do
                    for e = d + 1, n do

                        local used = { a, b, c, d, e }
                        local excluded = {}

                        for i = 1, n do
                            local isUsed = false
                            for _, u in ipairs(used) do
                                if i == u then
                                    isUsed = true
                                    break
                                end
                            end
                            if not isUsed then
                                table.insert(excluded, cards[i])
                            end
                        end

                        local newHand = Hand:new(
                            { cards[a], cards[b], cards[c], cards[d], cards[e] },
                            excluded
                        )
                        table.insert(combos, newHand)
                    end
                end
            end
        end
    end

    return combos
end

local hands = makeCardCombos(fullHand)

print("*** Hand Combinations...\n")
for _, h in ipairs(hands) do
    h:printHand()
end
print()

---------------------------------------------------------------------
-- 3. SORT hands using handValue + tiebreakers
---------------------------------------------------------------------
local function compareHands(h1, h2)
    if h1.handValue ~= h2.handValue then
        return h1.handValue < h2.handValue
    end

    local label = h1.label

    if label == "High Card" then
        return Tiebreak.highCardTB(h1, h2)
    elseif label == "Pair" then
        return Tiebreak.pairTB(h1, h2)
    elseif label == "Two Pair" then
        return Tiebreak.twoPairTB(h1, h2)
    elseif label == "Three of a Kind" then
        return Tiebreak.threeTB(h1, h2)
    elseif label == "Straight" then
        return Tiebreak.straightTB(h1, h2)
    elseif label == "Flush" then
        return Tiebreak.flushTB(h1, h2)
    elseif label == "Full House" then
        return Tiebreak.fullHouseTB(h1, h2)
    elseif label == "Four of a Kind" then
        return Tiebreak.fourTB(h1, h2)
    elseif label == "Straight Flush" or label == "Royal Straight Flush" then
        return Tiebreak.straightFlushTB(h1, h2)
    end

    return false
end

local function sortHands(hands)
    local swapped = true
    while swapped do
        swapped = false
        for i = 1, #hands - 1 do
            if compareHands(hands[i], hands[i+1]) then
                hands[i], hands[i+1] = hands[i+1], hands[i]
                swapped = true
            end
        end
    end
end

sortHands(hands)

---------------------------------------------------------------------
-- 4. Print final ranking + track statistics
---------------------------------------------------------------------
print("--- HIGH HAND ORDER ---\n")

for _, h in ipairs(hands) do
    h:printWithLabel()
    statsCount[h.label] = statsCount[h.label] + 1
end

print()
print("*** STATISTICAL ANALYSIS ***\n")

local order = {
    "Royal Straight Flush",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card"
}

for _, name in ipairs(order) do
    print(string.format("%-22s : %d", name, statsCount[name]))
end

print()
