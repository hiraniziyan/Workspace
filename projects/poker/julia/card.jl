mutable struct Card
	rank::String
	suit::String
end

function toString(card::Card)
	return card.rank * card.suit
end

function rankValue(card::Card)
	if card.rank == "A"  # A is the highest so it returns 14 rather than 1
		return 14
	elseif card.rank == "K"
		return 13
	elseif card.rank == "Q"
		return 12
	elseif card.rank == "J"
		return 11
	elseif card.rank == "10"
		return 10
	else
		return parse(Int, card.rank)
	end
end

function suitValue(card::Card)
	if card.suit == "D"
		return 1
	elseif card.suit == "C"
		return 2
	elseif card.suit == "H"
		return 3
	elseif card.suit == "S"
		return 4
	end

	return 0
end

function equals(card1::Card, otherCard::Card)
	return card1.rank == otherCard.rank && card1.suit == otherCard.suit
end

