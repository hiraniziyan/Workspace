local Card = require("Card")

local Deck = {}
Deck.__index = Deck

math.randomseed(os.time())

function Deck.new()
    local this = setmetatable({}, Deck)
    this.deck = {}

    local nums = {"2","3","4","5","6","7","8","9","10","J","Q","K","A"}
    local suits = {"S","H","C","D"}

    for _, suit in ipairs(suits) do
        for _, num in ipairs(nums) do
            table.insert(this.deck, Card:new(num .. suit))
        end
    end

    for i = #this.deck, 1, -1 do
        local j = math.random(1, i)
        this.deck[i], this.deck[j] = this.deck[j], this.deck[i]
    end

    return this
end

function Deck.joker()
    local this = setmetatable({}, Deck)
    this.deck = {}

    local nums = {"2","3","4","5","6","7","8","9","10","J","Q","K","A"}
    local suits = {"S","H","C","D"}

    for _, suit in ipairs(suits) do
        for _, num in ipairs(nums) do
            table.insert(this.deck, Card:new(num .. suit))
        end
    end

    local jokerR = Card:new("XR")
    local jokerB = Card:new("XB")
    table.insert(this.deck, jokerR)
    table.insert(this.deck, jokerB)

    for i = #this.deck, 1, -1 do
        local j = math.random(1, i)
        this.deck[i], this.deck[j] = this.deck[j], this.deck[i]
    end

    return this
end

function Deck:printDeck()
    print("\n *** Shuffled Deck *** \n")
    for i = 1, #self.deck do
        io.write(string.format("%-4s", tostring(self.deck[i])))
        if i % 13 == 0 then
            print()
        end
    end
    print()
end

function Deck:deal()
    local hand = {}
    for i = 1, 8 do
        table.insert(hand, self.deck[i])
    end
    return hand
end

return Deck
