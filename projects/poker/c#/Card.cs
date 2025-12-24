using System;

public class Card
{
	public string rank;
	public string suit;

	public Card()
	{
		this.rank = "";
		this.suit = "";
	}

	public Card(string rank, string suit)
	{
		this.rank = rank;
		this.suit = suit;
	}

	public string toString()
	{
		return rank + suit;
	}

	public int rankValue()
	{
		if (rank == "A") // A is the highest so it returns 14 rather than 1
			return 14;
		if (rank == "K")
			return 13;
		if (rank == "Q")
			return 12;
		if (rank == "J")
			return 11;
		if (rank == "10")
			return 10;
		return int.Parse(rank);
	}

	public int suitValue()
	{
		if (suit == "D")
			return 1;
		if (suit == "C")
			return 2;
		if (suit == "H")
			return 3;
		if (suit == "S")
			return 4;
		return 0;
	}

	public bool equals(Card otherCard)
	{
		return this.rank == otherCard.rank && this.suit == otherCard.suit;
	}
}

