using System;
using System.Collections.Generic;

public class Hand
{
	public int handValue;
	public string label;
	public Card highestCard;
	public List<Card> cards;
	public List<Card> originalOrder;
	public Card excluded;

	public Hand(List<Card> c, Card e)
	{
		this.cards = new List<Card>(c);
		this.excluded = e;
		this.originalOrder = c;
		findWin();
	}

	public void printHand()
	{
		// print cards in correct format
		for (int i = 0; i < originalOrder.Count; i++)
		{
			Console.Write("{0,2}{1,-2}", originalOrder[i].rank, originalOrder[i].suit);
		}
		Console.WriteLine("| {0,2}{1,-2}", excluded.rank, excluded.suit);
	}

	public void printWithLabel()
	{
		// print cards with win label
		for (int i = cards.Count - 1; i >= 0; i--)
		{
			Console.Write("{0,2}{1,-2}", cards[i].rank, cards[i].suit);
		}
		Console.WriteLine("| {0,2}{1,-2}-- {2}", excluded.rank, excluded.suit, label);
	}

	public bool lessThan(Hand otherHand)
	{
		return this.handValue < otherHand.handValue;
	}

	public void bubbleSortCards()
	{
		// bubble sort from least to greatest
		for (int i = 0; i < cards.Count; i++)
		{
			for (int j = 0; j < cards.Count - i - 1; j++)
			{
				if (cards[j].rankValue() > cards[j + 1].rankValue() ||
						(cards[j].rankValue() == cards[j + 1].rankValue() &&
						 cards[j].suitValue() > cards[j + 1].suitValue()))
				{
					Card temp = cards[j];
					cards[j] = cards[j + 1];
					cards[j + 1] = temp;
				}
			}
		}
	}

	public bool isFlush()
	{
		// checks if all suits are the same as the suit of the card before
		for (int i = 0; i < cards.Count - 1; i++)
		{
			if (cards[i].suit != cards[i + 1].suit)
				return false;
		}
		label = "Flush";
		handValue = 6;
		highestCard = cards[4];
		return true;
	}

	public bool isStraight()
	{
		// check manually for ace low straight
		if (cards[0].rankValue() == 2 && cards[1].rankValue() == 3 && cards[2].rankValue() == 4
				&& cards[3].rankValue() == 5 && cards[4].rankValue() == 14)
		{
			label = "Straight";
			handValue = 5;
			highestCard = cards[3];
			return true;
		}

		for (int i = 0; i < cards.Count - 1; i++)
			if (cards[i].rankValue() + 1 != cards[i + 1].rankValue())
				return false;

		label = "Straight";
		handValue = 5;
		highestCard = (cards[4].rankValue() == 14) ? cards[3] : cards[4];
		return true;
	}

	public bool checkPair()
	{
		// checks if next card has the same rank value as current because cards are already sorted
		for (int i = 0; i < cards.Count - 1; i++)
		{
			if (cards[i].rankValue() == cards[i + 1].rankValue())
			{
				label = "Pair";
				handValue = 2;
				highestCard = cards[i + 1];
				return true;
			}
		}
		return false;
	}

	public bool checkThree()
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

	public bool checkFour()
	{
		// checks both combinations manually and assigns field values
		if (cards[0].rankValue() == cards[1].rankValue() &&
				cards[1].rankValue() == cards[2].rankValue() &&
				cards[2].rankValue() == cards[3].rankValue())
		{
			label = "Four of a Kind";
			handValue = 8;
			highestCard = cards[4];
			return true;
		}
		if (cards[1].rankValue() == cards[2].rankValue() &&
				cards[2].rankValue() == cards[3].rankValue() &&
				cards[3].rankValue() == cards[4].rankValue())
		{
			label = "Four of a Kind";
			handValue = 8;
			highestCard = cards[0];
			return true;
		}
		return false;
	}

	public bool checkFullHouse()
	{
		// check the three pair and then the two pair for both possible combinations
		if (cards[0].rankValue() == cards[1].rankValue() && cards[1].rankValue() == cards[2].rankValue())
		{
			if (cards[3].rankValue() == cards[4].rankValue())
			{
				label = "Full House";
				handValue = 7;
				highestCard = cards[2];
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

	public bool checkTwoPair()
	{
		bool hasOnePair = false;
		int kickerCardPos = -1;

		for (int i = 0; i < cards.Count - 1; i++)
		{
			if (cards[i].rankValue() == cards[i + 1].rankValue())
			{
				if (!hasOnePair)
				{
					hasOnePair = true;
				}
				else
				{
					label = "Two Pair";
					handValue = 3;

					// store the kicker card in the highest card
					if (kickerCardPos != -1)
						highestCard = cards[kickerCardPos];
					else
						highestCard = cards[4];
					return true;
				}
				i++;
			}
			else
			{
				kickerCardPos = i; // store the position of the card not part of either pair
			}
		}
		return false;
	}

	public void findWin()
	{
		bubbleSortCards();

		if (isStraight() && isFlush())
		{
			if (cards[4].rankValue() == 14 && cards[3].rankValue() == 13)
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

				// if ace low straight, move ace to front
				if (cards[4].rankValue() == 14 && cards[0].rankValue() == 2)
				{
					Card ace = cards[4];
					for (int i = 4; i > 0; i--)
					{
						cards[i] = cards[i - 1];
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
			// if ace low straight, move ace to the front
			if (cards[4].rankValue() == 14 && cards[0].rankValue() == 2)
			{
				Card ace = cards[4];
				for (int i = 4; i > 0; i--)
				{
					cards[i] = cards[i - 1];
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
}
