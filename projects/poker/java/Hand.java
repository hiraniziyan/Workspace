import java.util.*;

public class Hand
{
	public int handValue;
	public String label;
	public Card highestCard;
	public List<Card> cards;
	public List<Card> originalOrder;
	public Card excluded;

	public Hand(List<Card> c, Card e)
	{
		this.cards = new ArrayList<>(c);
		this.excluded = e;
		this.originalOrder = new ArrayList<>(c);
		findWin();
	}
	
	public void printHand()
	{
		// print cards in correct format
		for (int i = 0; i < originalOrder.size(); i++) {
			Card c = originalOrder.get(i);
			System.out.printf("%2s%-2s", c.rank, c.suit);
		}
		System.out.printf("| %2s%-2s%n", excluded.rank, excluded.suit);	
	}
	
	public void printWithLabel()
	{
		// print cards with win label
		for (int i = cards.size() - 1; i >= 0; i--) {
                        Card c = cards.get(i);
                        System.out.printf("%2s%-2s", c.rank, c.suit);
                }
                System.out.printf("| %2s%-2s-- %s%n", excluded.rank, excluded.suit, label);
	}

	public boolean lessThan(Hand otherHand)
	{
		return this.handValue < otherHand.handValue;
	}

	public void bubbleSortCards() 
	{
		// bubble sort from least to greatest
		for (int i = 0; i < cards.size(); i++) 
		{
			for (int j = 0; j < cards.size() - i - 1; j++) 
			{
				if (cards.get(j).rankValue() > cards.get(j+1).rankValue() ||
						(cards.get(j).rankValue() == cards.get(j+1).rankValue() &&
						 cards.get(j).suitValue() > cards.get(j+1).suitValue())) 
				{
					Collections.swap(cards, j, j+1);
				}
			}
		}
	}
	
	public boolean isFlush()
	{	
		// cheks if all suits are the same as the suit of the card before
		for (int i = 0; i < cards.size() - 1; i++)
		{
			if (!cards.get(i).suit.equals(cards.get(i+1).suit))
			{
				return false;
			}
		}
		label = "Flush";
		handValue = 6;
		highestCard = cards.get(4);
		return true;
	}	
	
	public boolean isStraight()
	{	
		// check manually for ace low straight
		if (cards.get(0).rankValue() == 2 && cards.get(1).rankValue() == 3 && cards.get(2).rankValue() == 4 
			&& cards.get(3).rankValue() == 5 && cards.get(4).rankValue() == 14)
		{
			label = "Straight";
			handValue = 5;
			highestCard = cards.get(3); 
			return true;
		}

		for (int i = 0; i < cards.size() - 1; i++)
		{
			// checks for straights by iterating and checking if value of the next card is current card + 1
			if (cards.get(i).rankValue() + 1 != cards.get(i+1).rankValue())
			{
				return false;
			}
		}
	
		label = "Straight";
        	handValue = 5;
        	highestCard = (cards.get(4).rankValue() == 14) ? cards.get(3) : cards.get(4);
		return true;
	} 
	
	public boolean checkPair()
	{
		// checks if next card has the same rank value as current because cards are already sorted
		for (int i = 0; i < cards.size() - 1; i++)
		{
			if (cards.get(i).rankValue() == cards.get(i+1).rankValue())
			{
				label = "Pair";
				handValue = 2;
				highestCard = cards.get(i+1);
				return true;
			}
		}
		return false;
	}

	public boolean checkThree()
	{
		// checks all three combinations manually and assigns field values (highest card == last card in the three of a kind)
		if (cards.get(0).rankValue() == cards.get(1).rankValue() && cards.get(1).rankValue() == cards.get(2).rankValue()) 
		{
			label = "Three of a Kind"; 
			handValue = 4; 
			highestCard = cards.get(2); 
			return true;
		}
		if (cards.get(1).rankValue() == cards.get(2).rankValue() && cards.get(2).rankValue() == cards.get(3).rankValue())
		{
			label = "Three of a Kind"; 
			handValue = 4; 
			highestCard = cards.get(3); 
			return true;
		}
		if (cards.get(2).rankValue() == cards.get(3).rankValue() && cards.get(3).rankValue() == cards.get(4).rankValue()) 
		{
			label = "Three of a Kind"; 
			handValue = 4; 
			highestCard = cards.get(4); 
			return true;
		}
		return false;
	}

	public boolean checkFour()
	{
		// checks both combinations manually and assigns field values
		if (cards.get(0).rankValue() == cards.get(1).rankValue() &&
			cards.get(1).rankValue() == cards.get(2).rankValue() &&
			cards.get(2).rankValue() == cards.get(3).rankValue()) 
		{
			label = "Four of a Kind"; 
			handValue = 8; 
			highestCard = cards.get(4); 
			return true;
		}
		if (cards.get(1).rankValue() == cards.get(2).rankValue() &&
			cards.get(2).rankValue() == cards.get(3).rankValue() &&
			cards.get(3).rankValue() == cards.get(4).rankValue()) 
		{
			label = "Four of a Kind"; 
			handValue = 8; 
			highestCard = cards.get(0); 
			return true;
		}
		return false;
	}

	public boolean checkFullHouse() 
	{
		// check the three pair and then the two pair for both possible combinations
		if (cards.get(0).rankValue() == cards.get(1).rankValue() && cards.get(1).rankValue() == cards.get(2).rankValue()) 
		{
			if (cards.get(3).rankValue() == cards.get(4).rankValue()) 
			{
				label = "Full House"; 
				handValue = 7; 
				highestCard = cards.get(2); 	
				return true;
			}
		} 
		else if (cards.get(2).rankValue() == cards.get(3).rankValue() && cards.get(3).rankValue() == cards.get(4).rankValue()) 
		{
			if (cards.get(0).rankValue() == cards.get(1).rankValue()) 
			{
				label = "Full House"; 
				handValue = 7;
				highestCard = cards.get(4); 
				return true;
			}
		}
		return false;
	}
	
	public boolean checkTwoPair() 
	{
		boolean hasOnePair = false;
		int kickerCardPos = -1;

		for (int i = 0; i < cards.size() - 1; i++) 
		{
			if (cards.get(i).rankValue() == cards.get(i+1).rankValue()) 
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
						highestCard = cards.get(kickerCardPos);
					else 
						highestCard = cards.get(4); 
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
			if (cards.get(4).rankValue() == 14 && cards.get(3).rankValue() == 13) 
			{
				label = "Royal Straight Flush"; 
				handValue = 10; 
				highestCard = cards.get(4);
			} 
			else 
			{
				label = "Straight Flush"; 
				handValue = 9; 
				highestCard = cards.get(4);

				// if ace low straight, move ace to front
				if (cards.get(4).rankValue() == 14 && cards.get(0).rankValue() == 2) 
				{
					Card ace = cards.get(4);
					for (int i = 4; i > 0; i--) 
					{
						cards.set(i, cards.get(i-1));
					}
					cards.set(0, ace);
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
			if (cards.get(4).rankValue() == 14 && cards.get(0).rankValue() == 2) 
			{
				Card ace = cards.get(4);
				for (int i = 4; i > 0; i--) 
				{
					cards.set(i, cards.get(i-1));
				}
				cards.set(0, ace);
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
		highestCard = cards.get(4);
	}

}



