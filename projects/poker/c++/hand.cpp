#include "hand.h"
#include <algorithm>

Hand::Hand(vector<Card> c, Card e) 
{
	cards = c;
	originalOrder = c;	
	excluded = e;	// contains the card that was left out of hand
	findWin();	// evaluate type of win for hand
}

void Hand::toString()
{
	for (int i = 0; i < originalOrder.size(); i++)
	{
		printf("%2s%-2s", originalOrder[i].rank.c_str(), originalOrder[i].suit.c_str()); 
	}
	printf("| %2s%-2s\n", excluded.rank.c_str(), excluded.suit.c_str());
}

void Hand::printWithLabel()
{
	for (int i = cards.size() - 1; i >= 0; i--)
	{
		printf("%2s%-2s", cards[i].rank.c_str(), cards[i].suit.c_str());
	}
	printf("| %2s%-2s-- %s\n", excluded.rank.c_str(), excluded.suit.c_str(), label.c_str());
}

bool Hand::operator<(const Hand& other) const	// operator overloaded method to compare value of two hands
{
	if (handValue != other.handValue)
	{
		return handValue < other.handValue;
	}
	return false;
}

void Hand::bubbleSortCards()	// sorts the cards based on rank value and suit value from least to greatest
{
	for (int i = 0; i < cards.size(); i++)
	{
		for (int j = 0; j < cards.size() - i - 1; j++)
		{
			if (cards[j].rankValue() > cards[j+1].rankValue() || (cards[j].rankValue() == cards[j+1].rankValue() &&
						cards[j].suitValue() > cards[j+1].suitValue()))
			{
				swap(cards[j], cards[j+1]);
			}
		}
	}
}

bool Hand::isFlush()	
{	
	// cheks if all suits are the same as the first card suit
	for (int i = 1; i < cards.size(); i++)
	{
		if (cards[i].suit != cards[0].suit)
		{
			return false;
		}
	}
	
	// assign fields
	label = "Flush";
	handValue = 6;
	highestCard = cards[4]; // set highest card to last card in hand (because they are sorted from lowest to highest)

	return true;
}

bool Hand::isStraight()	
{
	// checks for A, 2, 3, 4, 5
	if (cards[0].rankValue() == 2 && cards[1].rankValue() == 3 && cards[2].rankValue() == 4 && cards[3].rankValue() == 5 && cards[4].rankValue() == 14)
	{
		label = "Straight";
		handValue = 5;
		highestCard = cards[4];
		return true;
	}

	// checks for straights by iterating and checking if value of the next card is current card + 1
	for (int i = 0; i < cards.size() - 1; i++)
	{
		if (cards[i+1].rankValue() != cards[i].rankValue() + 1)
		{
			return false;
		}
	}

	// assign fields
	label = "Straight";
	handValue = 5;
	highestCard = (cards[4].rankValue() == 14) ? cards[3] : cards[4]; // set the highest card in deck to the last card in the vector unless it is an ace

	return true;
}

bool Hand::checkPair() 
{
	// checks if next card has the same rank value as current because cards are already sorted
	for (int i = 0; i + 1 < cards.size(); i++)
	{
		// if pair is found --> assign fields
		if (cards[i].rankValue() == cards[i+1].rankValue())
		{
			label = "Pair";
			handValue = 2;
			highestCard = cards[i+1]; // set highest card to second card in the pair
			return true;
		}
	}
	return false;
}

bool Hand::checkThree() 
{
	// checks all three combinations manually and assigns field values (highest card == last card in the three of a kind)
	if (cards[0].rankValue() == cards[1].rankValue() && cards[1].rankValue() == cards[2].rankValue())
	{
		label = "Three of a Kind";
		handValue = 4;
		highestCard = cards[2];
		return true;
	}

	if (cards[1].rankValue() == cards[2].rankValue() && cards[2].rankValue() == cards[3].rankValue())
	{
		label = "Three of a Kind";
		handValue = 4;
		highestCard = cards[3];
		return true;
	}

	if (cards[2].rankValue() == cards[3].rankValue() && cards[3].rankValue() == cards[4].rankValue())
	{
		label = "Three of a Kind";
		handValue = 4;
		highestCard = cards[4];
		return true;
	}

	return false;
}

bool Hand::checkFour() 
{
	// checks both combinations manually and assigns field values 
	if (cards[0].rankValue() == cards[1].rankValue() && cards[1].rankValue() == cards[2].rankValue() && cards[2].rankValue() == cards[3].rankValue())
	{
		label = "Four of a Kind";
		handValue = 8;
		highestCard = cards[4]; // set highest card to only card not included in four of a kind (it is the only card that matters for tiebreakers)
		return true;
	}

	if (cards[1].rankValue() == cards[2].rankValue() && cards[2].rankValue() == cards[3].rankValue() && cards[3].rankValue() == cards[4].rankValue())
	{
		label = "Four of a Kind";
		handValue = 8;
		highestCard = cards[0];
		return true;
	}

	return false;
}

bool Hand::checkTwoPair() 
{
	bool hasOnePair = false;	// variable for determining at least one pair
	int kickerCardPos = -1;

	for (int i = 0; i < cards.size() - 1; i++)	
	{
		if (cards[i].rankValue() == cards[i+1].rankValue())
		{
			if (!hasOnePair)	// set hasOnePair to true upon finding first pair
			{
				hasOnePair = true;
			}
			else	// if another pair is found set values for two pair
			{
				label = "Two Pair";
				handValue = 3;
				if (kickerCardPos != -1)
					highestCard = cards[kickerCardPos];
				else
					highestCard = cards[4]; 
				
				return true;
			}
			i++; 
		}
		else
			kickerCardPos = i;

	}

	return false;
}

bool Hand::checkFullHouse()	
{

	if (cards[0].rankValue() == cards[1].rankValue() && cards[1].rankValue() == cards[2].rankValue())
	{
		if (cards[3].rankValue() == cards[4].rankValue())
		{
			label = "Full House";
			handValue = 7;
			highestCard = cards[2]; // set highest card to last card in the triple
			return true;
		}
	}
	else if (cards[2].rankValue() == cards[3].rankValue() && cards[3].rankValue() == cards[4].rankValue())
	{
		if (cards[0].rankValue() == cards[1].rankValue())
		{
			label = "Full House";
			handValue = 7;
			highestCard = cards[4];
			return true;
		}
	}


	return false;
}

void Hand::findWin()	// find the type of win for the hand
{
	bubbleSortCards(); 
	
	// checks each type of win in order of value
	if (isStraight() && isFlush())	// check for straight and flush
	{
		if (cards[4].rankValue() == 14 && cards[3].rankValue() == 13)	// if the straight and flush contains an ace and king --> royal straight flush
		{
			label = "Royal Straight Flush";
			handValue = 10;
			highestCard = cards[4]; 
		}
		else
		{
			label = "Straight Flush";
			handValue = 9;
			highestCard = cards[4];
			
			// if hand is ace-low, move ace to front
			if (cards[4].rankValue() == 14 && cards[0].rankValue() == 2)
			{
				Card ace = cards[4];
				for (int i = 4; i > 0; i--)
				{
					cards[i] = cards[i-1];
				}
				cards[0] = ace;
			}
		}
		return;
	}

	if (checkFour()) 
		return;

	if (checkFullHouse()) 
		return;

	if (isFlush())
		return;


	if (isStraight())	
	{
		if (cards[4].rankValue() == 14 && cards[0].rankValue() == 2)
		{
			Card ace = cards[4];
			for (int i = 4; i > 0; i--)
			{
				cards[i] = cards[i-1];
			}
			cards[0] = ace;
		}

		return;
	}

	if (checkThree()) 
		return;

	if (checkTwoPair()) 
		return;

	if (checkPair()) 
		return;

	label = "High Card";
	handValue = 1;
	highestCard = cards[4]; 
}
