local Card = require("Card")

local Hand = {}
Hand.__index = Hand

local rankVals = {
    ["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,
    ["7"]=7,["8"]=8,["9"]=9,["10"]=10,
    ["J"]=11,["Q"]=12,["K"]=13,["A"]=14
}

---------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------
function Hand:new(cards, excluded)
    -- create Hand object
    local this = setmetatable({}, Hand)

    -- copy the cards into the the hand.card array
    this.cards = cards
    this.excluded = excluded -- copy the excluded cards into the excluded cards array

    this.winType = ""                   -- holds type of win
    this.handStrength = 0               -- holds strength of the hand
    this.tieBreakerHelperCard = nil     -- holds a card that helps with tiebreaker

    this:evaluate()                     -- evaluate the type of win
    return this
end

function Hand:sortCards()
    table.sort(self.cards, function(a, b)
        if a.rank.value ~= b.rank.value then
            return a.rank.value < b.rank.value
        end
        return a.suit.strength < b.suit.strength
    end)
end

function Hand:isFlush()
    local s = self.cards[1].suit.symbol
    for i = 2, 5 do
        if self.cards[i].suit.symbol ~= s then
            return false
        end
    end
    return true
end

function Hand:isStraight()
    if self.cards[1].rank.value == 2 and
       self.cards[2].rank.value == 3 and
       self.cards[3].rank.value == 4 and
       self.cards[4].rank.value == 5 and
       self.cards[5].rank.value == 14 then
        return true
    end

    for i = 1, 4 do
        if self.cards[i].rank.value + 1 ~= self.cards[i+1].rank.value then
            return false
        end
    end

    return true
end


function Hand:getCounts()
    local counts = {}
    for _, c in ipairs(self.cards) do
        local w = c.rank.value
        counts[w] = (counts[w] or 0) + 1
    end

    local numPairs, numTrips, numQuads = 0, 0, 0
    for _, count in pairs(counts) do
        if count == 2 then numPairs = numPairs + 1 end
        if count == 3 then numTrips = numTrips + 1 end
        if count == 4 then numQuads = numQuads + 1 end
    end

    return numPairs, numTrips, numQuads, counts
end


function Hand:getTieBreakerCard(countWanted, counts)
    -- find the first card whose count appears to be countWanted
    for rank, count in pairs(counts) do
        if count == countWanted then
            for _, c in ipairs(self.cards) do
                if c.rank.value == rank then
                    return c
                end
            end
        end
    end
    return nil
end


function Hand:evaluate()
    self:sortCards()

    local isStraight = self:isStraight()
    local isFlush = self:isFlush()
    local numPairs, numTrips, numQuads, counts = self:getCounts()

    -- Straight Flush / Royal
    if isStraight and isFlush then
        -- check if the straight and flush contain an ace and a king
        if self.cards[5].rank.value == 14 and self.cards[4].rank.value == 13 then
            self.winType = "Royal Straight Flush"
            self.handStrength = 10
        else
            self.winType = "Straight Flush"
            self.handStrength = 9
        end
        return
    end

    -- Four of a Kind
    if numQuads > 0 then
        self.winType = "Four of a Kind"
        self.handStrength = 8
        self.tieBreakerHelperCard = self:getTieBreakerCard(4, counts)
        return
    end

    -- Full House
    if numTrips > 0 and numPairs > 0 then
        self.winType = "Full House"
        self.handStrength = 7
        self.tieBreakerHelperCard = self:getTieBreakerCard(3, counts) -- get one card from the tripple
        return
    end

    -- Flush
    if isFlush then
        self.winType = "Flush"
        self.handStrength = 6
        return
    end

    -- Straight
    if isStraight then
        self.winType = "Straight"
        self.handStrength = 5
        return
    end

    -- Three of a Kind
    if numTrips > 0 then
        self.winType = "Three of a Kind"
        self.handStrength = 4
        self.tieBreakerHelperCard = self:getTieBreakerCard(3, counts) -- get one card from the tripple
        return
    end

    -- Two Pair
    if numPairs == 2 then
      self.winType = "Two Pair"
      self.handStrength = 3

      local pairRanks = {}
      local kickerRank = nil

      -- Identify the two pair ranks and kicker rank
      for rank, count in pairs(counts) do
          if count == 2 then
              table.insert(pairRanks, rank)
          elseif count == 1 then
              kickerRank = rank
          end
      end

      -- Find the kicker card object
      for _, c in ipairs(self.cards) do
          if c.rank.value == kickerRank then
              self.tieBreakerHelperCard = c
              break
          end
      end

      return
    end

    -- One Pair
    if numPairs == 1 then
        self.winType = "Pair"
        self.handStrength = 2
        self.tieBreakerHelperCard = self:getTieBreakerCard(2, counts) -- get one card from the pair
        return
    end

    -- High Card
    self.winType = "High Card"
    self.handStrength = 1
end


return Hand

