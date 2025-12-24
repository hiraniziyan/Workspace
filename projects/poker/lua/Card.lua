local Card = {}
Card.__index = Card

-- Suit enum defined
Card.Suit = {
    DIAMONDS = { symbol = 'D', strength = 1 },
    CLUBS    = { symbol = 'C', strength = 2 },
    HEARTS   = { symbol = 'H', strength = 3 },
    SPADES   = { symbol = 'S', strength = 4 }
}

-- Rank enum defined
Card.Rank = {
    TWO   = { symbol = '2', value = 2 },
    THREE = { symbol = '3', value = 3 },
    FOUR  = { symbol = '4', value = 4 },
    FIVE  = { symbol = '5', value = 5 },
    SIX   = { symbol = '6', value = 6 },
    SEVEN = { symbol = '7', value = 7 },
    EIGHT = { symbol = '8', value = 8 },
    NINE  = { symbol = '9', value = 9 },
    TEN   = { symbol = 'T', value = 10 },
    JACK  = { symbol = 'J', value = 11 },
    QUEEN = { symbol = 'Q', value = 12 },
    KING  = { symbol = 'K', value = 13 },
    ACE   = { symbol = 'A', value = 14 }
}

-- lookups for both rank and suit by symbol
local rankLookup = {}
for _, r in pairs(Card.Rank) do
    rankLookup[r.symbol] = r
end

local suitLookup = {}
for _, s in pairs(Card.Suit) do
    suitLookup[s.symbol] = s
end

-- Constructor for card class
function Card:new(cardStr)
    if not cardStr or #cardStr < 2 or #cardStr > 3 then
        error("Invalid card string: " .. tostring(cardStr))
    end

    -- Separates the rank and the suit
    local rankStr = cardStr:sub(1, #cardStr - 1)
    local suitChar = cardStr:sub(#cardStr)

    -- Converts 10 to T so there is no confusion for a single double digit
    local rankChar = (rankStr == "10") and 'T' or rankStr:sub(1,1)
    local rank = rankLookup[rankChar]
    local suit = suitLookup[suitChar]

    if not rank then
        error("Invalid rank: " .. rankChar)
    end
    if not suit then
        error("Invalid suit: " .. suitChar)
    end

    -- Creates new card object
    local self = setmetatable({}, Card)
    self.rank = rank
    self.suit = suit
    return self
end

-- Getter methods
function Card:getRank() return self.rank.value end
function Card:getSuit() return self.suit.strength end

-- CompareTo method for sorting cards by rank and then suit strength
function Card:compareTo(other)
    if self.rank.value < other.rank.value then return -1 end
    if self.rank.value > other.rank.value then return 1 end

    if self.suit.strength < other.suit.strength then return -1 end
    if self.suit.strength > other.suit.strength then return 1 end

    return 0
end

-- ToString method
function Card:toString()
    local rankStr = (self.rank.symbol == 'T') and "10" or self.rank.symbol
    return rankStr .. self.suit.symbol
end

-- Equals method, checks for duplicates
function Card:equals(other)
    return self.rank == other.rank and self.suit == other.suit
end

-- No built in hashmap like java but stores cards in sets/tables
function Card:hashCode()
    return self.rank.value * 10 + self.suit.strength
end

-- Allows toString to actually work
function Card:__tostring()
    return self:toString()
end

return Card
