local Tiebreak = {}

---------------------------------------------------------------------
-- High Card Tie Breaker
-- Compare each card from highest to lowest rank,
-- Compare suits when ranks are equal
---------------------------------------------------------------------
function Tiebreak.highCardTB(hand1, hand2)
	-- loop from the back of cards assuming they are in sorted order
	for i = #hand1.cards, 1, -1 do
		local cardHand1 = hand1.cards[i]
		local cardHand2 = hand2.cards[i]

		-- Compare rank first
		if cardHand1:getRank() > cardHand2:getRank() then
			return false
		elseif cardHand1:getRank() < cardHand2:getRank() then
			return true
		else
			-- if ranks are equal compare suit strength
			if cardHand1:getSuit() > cardHand2:getSuit() then
				return false
			elseif cardHand1:getSuit() < cardHand2:getSuit() then
				return true
			end
		end
	end

	return false
end

---------------------------------------------------------------------
-- Pair Tie Breaker
-- Compare the pair first, then compare kickers.
---------------------------------------------------------------------
function Tiebreak.pairTB(hand1, hand2)
	-- arrays to hold the pairs and kickers of both hands
	local pairCardsHand1 = {}
	local pairCardsHand2 = {}
	local kickerCardsHand1 = {}
	local kickerCardsHand2 = {}

	-- Separate pair cards and kicker cards in hand1
	for _, card in ipairs(hand1.cards) do
		if card:getRank() == hand1.tieBreakerHelperCard:getRank() then
			table.insert(pairCardsHand1, card)
		else
			table.insert(kickerCardsHand1, card)
		end
	end

	-- Separate pair cards and kicker cards in hand2
	for _, card in ipairs(hand2.cards) do
		if card:getRank() == hand2.tieBreakerHelperCard:getRank() then
			table.insert(pairCardsHand2, card)
		else
			table.insert(kickerCardsHand2, card)
		end
	end

	-- Compare pair cards first (rank then suit)
	for i = #pairCardsHand1, 1, -1 do
		local card1 = pairCardsHand1[i]
		local card2 = pairCardsHand2[i]

		if card1:getRank() > card2:getRank() then
			return false
		elseif card1:getRank() < card2:getRank() then
			return true
		else
			if card1:getSuit() > card2:getSuit() then
				return false
			elseif card1:getSuit() < card2:getSuit() then
				return true
			end
		end
	end

	-- If pair cards are the same compare kicker cards (rank then suit)
	for i = #kickerCardsHand1, 1, -1 do
		local kicker1 = kickerCardsHand1[i]
		local kicker2 = kickerCardsHand2[i]

		if kicker1:getRank() > kicker2:getRank() then
			return false
		elseif kicker1:getRank() < kicker2:getRank() then
			return true
		else
			if kicker1:getSuit() > kicker2:getSuit() then
				return false
			elseif kicker1:getSuit() < kicker2:getSuit() then
				return true
			end
		end
	end

	return false
end

---------------------------------------------------------------------
-- Three of a Kind Tie Breaker
-- Compare the triple first, then compare kickers.
---------------------------------------------------------------------
function Tiebreak.threeTB(hand1, hand2)
	-- arrays to hold the triples and kickers of both hands
	local tripleCardsHand1 = {}
	local tripleCardsHand2 = {}
	local kickerCardsHand1 = {}
	local kickerCardsHand2 = {}

	-- Separate triples and kickers for hand1
	for _, card in ipairs(hand1.cards) do
		if card:getRank() == hand1.tieBreakerHelperCard:getRank() then
			table.insert(tripleCardsHand1, card)
		else
			table.insert(kickerCardsHand1, card)
		end
	end

	-- Separate triples and kickers for hand2
	for _, card in ipairs(hand2.cards) do
		if card:getRank() == hand2.tieBreakerHelperCard:getRank() then
			table.insert(tripleCardsHand2, card)
		else
			table.insert(kickerCardsHand2, card)
		end
	end

	-- Compare triples (rank then suit)
	for i = #tripleCardsHand1, 1, -1 do
		local card1 = tripleCardsHand1[i]
		local card2 = tripleCardsHand2[i]

		if card1:getRank() > card2:getRank() then
			return false
		elseif card1:getRank() < card2:getRank() then
			return true
		else
			if card1:getSuit() > card2:getSuit() then
				return false
			elseif card1:getSuit() < card2:getSuit() then
				return true
			end
		end
	end

	-- Compare kickers (rank then suit)
	for i = #kickerCardsHand1, 1, -1 do
		local kicker1 = kickerCardsHand1[i]
		local kicker2 = kickerCardsHand2[i]

		if kicker1:getRank() > kicker2:getRank() then
			return false
		elseif kicker1:getRank() < kicker2:getRank() then
			return true
		else
			if kicker1:getSuit() > kicker2:getSuit() then
				return false
			elseif kicker1:getSuit() < kicker2:getSuit() then
				return true
			end
		end
	end

	return false
end

---------------------------------------------------------------------
-- Four of a Kind Tie Breaker
-- Compare quad rank first, then the kicker card.
---------------------------------------------------------------------
function Tiebreak.fourTB(hand1, hand2)
	-- get a card that is part of the quad (to compare rank value)
	local quadRankHand1 = hand1.tieBreakerHelperCard:getRank()
	local quadRankHand2 = hand2.tieBreakerHelperCard:getRank()

	-- Compare quads
	if quadRankHand1 > quadRankHand2 then
		return false
	end
	if quadRankHand1 < quadRankHand2 then
		return true
	end

	local kickerCardHand1 = nil
	local kickerCardHand2 = nil

	-- get the card that is not part of the quad and set it to be the kicker card
	for _, card in ipairs(hand1.cards) do
		if card:getRank() ~= quadRankHand1 then
			kickerCardHand1 = card
			break
		end
	end

	for _, card in ipairs(hand2.cards) do
		if card:getRank() ~= quadRankHand2 then
			kickerCardHand2 = card
			break
		end
	end

	-- Compare kicker rank
	if kickerCardHand1:getRank() > kickerCardHand2:getRank() then
		return false
	end
	if kickerCardHand1:getRank() < kickerCardHand2:getRank() then
		return true
	end

	-- Compare kicker suit
	if kickerCardHand1:getSuit() > kickerCardHand2:getSuit() then 
		return false 
	end
	if kickerCardHand1:getSuit() < kickerCardHand2:getSuit() then 
		return true 
	end

	return false
end

---------------------------------------------------------------------
-- 2 Pair Tie Breaker
-- Compare highest pair, then second pair, then kicker.
---------------------------------------------------------------------
function Tiebreak.twoPairTB(hand1, hand2)
	local tbHand1 = {}
	local tbHand2 = {}

	-- Insert highest pair card first
	table.insert(tbHand1, hand1.tieBreakerHelperCard)
	table.insert(tbHand2, hand2.tieBreakerHelperCard)

	-- Then insert all remaining cards
	for i = 1, #hand1.cards do
		local card1 = hand1.cards[i]
		local card2 = hand2.cards[i]

		if not card1:equals(hand1.tieBreakerHelperCard) then
			table.insert(tbHand1, card1)
		end
		if not card2:equals(hand2.tieBreakerHelperCard) then
			table.insert(tbHand2, card2)
		end
	end

	-- Compare in descending order
	for i = #tbHand1, 1, -1 do
		local card1 = tbHand1[i]
		local card2 = tbHand2[i]

		if card1:getRank() > card2:getRank() then
			return false
		elseif card1:getRank() < card2:getRank() then
			return true
		elseif card1:getSuit() > card2:getSuit() then
			return false
		elseif card1:getSuit() < card2:getSuit() then
			return true
		end
	end

	return false
end

---------------------------------------------------------------------
-- Straight, Flush, Straight Flush, FullHouse tie-breakers:
---------------------------------------------------------------------
function Tiebreak.straightTB(h1, h2)
	-- Use highCardTB because comparing 2 straights requires checking the higher
	-- of the 2 straights, first by rank then suit (same logic as highCardTB)
	return Tiebreak.highCardTB(h1, h2)
end

function Tiebreak.straightFlushTB(h1, h2)
	-- Use highCardTB because comparing 2 straightFlushes requires checking the higher
	-- of the 2 straights (handled by highCardTB)
	return Tiebreak.highCardTB(h1, h2)
end

function Tiebreak.flushTB(h1, h2)
	-- Use highCardTB because comparing 2 flushes requires checking the higher
	-- of the 2 flushes, first by rank then suit (same logic as highCardTB)
	return Tiebreak.highCardTB(h1, h2)
end

function Tiebreak.fullHouseTB(h1, h2)
	-- same logic as the threeOfAKindTB because it requires checking the
	-- triple first then the other cards (in this case it is the pair)
	return Tiebreak.threeTB(h1, h2)
end

return Tiebreak
