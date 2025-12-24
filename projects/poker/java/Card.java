import java.util.*;

public class Card
{
	public String rank;
	public String suit;
	
	public Card()
	{
		this.rank = "";
		this.suit = "";
	}

	public Card(String rank, String suit)
	{
		this.rank = rank;
		this.suit = suit;
	}
	
	public String toString()
	{
		return rank + suit;
	}
	
	public int rankValue()
	{
		if (rank.equals("A")) // A is the highest so it returns 14 rather than 1
			return 14;
		if (rank.equals("K")) 
			return 13;
		if (rank.equals("Q")) 
			return 12;
		if (rank.equals("J")) 
			return 11;
		if (rank.equals("10")) 
			return 10;
		return Integer.parseInt(rank);
	}

	public int suitValue()
	{
		if (suit.equals("D"))
			return 1;
		if (suit.equals("C"))
			return 2;
		if (suit.equals("H"))
			return 3;
		if (suit.equals("S"))
			return 4;
		return 0;
	}

	public boolean equals(Card otherCard)
	{
		return this.rank.equals(otherCard.rank) && this.suit.equals(otherCard.suit);	
	}	
	
}
