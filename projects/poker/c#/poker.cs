using System;
using System.Collections.Generic;
using System.IO;

public class poker
{

	public static void Main(string[] args)
	{
		Console.WriteLine("\n*** P O K E R  H A N D  A N A L Y Z E R ***\n\n");

		List<Card> hand = new List<Card>();

		if (args.Length == 0)
		{
			Console.WriteLine("*** USING RANDOMIZED DECK OF CARDS ***");
			hand = generateDeck();  // get the six card hand
		}
		if (args.Length == 1)
		{
			string filename = args[0];
			Console.WriteLine("*** USING TEST DECK ***\n");
			Console.WriteLine("*** File: " + filename);
			hand = processFile(filename);   // get the six card hand
		}

		if (args.Length == 0)
		{
			Console.WriteLine("*** Here is the hand");
			printHand(hand);
		}

		List<Hand> hands = generateCombinations(hand);
		printWin(hands);
	}

	public static List<Card> generateDeck()
	{
		string[] suits = { "D", "C", "H", "S" };
		string[] ranks = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" };
		List<Card> allCards = new List<Card>();

		// generate 52 card deck
		foreach (string s in suits)
		{
			foreach (string r in ranks)
			{
				allCards.Add(new Card(r, s));
			}
		}

		Card[] deck = new Card[52];
		Random rand = new Random();

		// randomize deck and store card in non filled positions
		foreach (Card c in allCards)
		{
			int pos = rand.Next(52);
			while (deck[pos] != null)
			{
				pos = (pos + 1) % 52;
			}
			deck[pos] = c;
		}

		Console.WriteLine("\n*** Shuffled 52 card deck:");
		for (int i = 0; i < deck.Length; i++)
		{
			Console.Write(deck[i].toString() + " ");
			if ((i + 1) % 13 == 0)
				Console.WriteLine();
		}
		Console.WriteLine();

		List<Card> sixCardHand = new List<Card>();

		for (int i = 0; i < 6; i++)
			sixCardHand.Add(deck[i]);
		return sixCardHand;
	}

	public static void printHand(List<Card> hand)
	{
		Console.Write(" ");
		foreach (Card c in hand)
			Console.Write(c.toString() + " ");
		Console.WriteLine("\n");
	}

	public static List<Hand> generateCombinations(List<Card> hand)
	{
		List<Hand> hands = new List<Hand>();

		int cardIndexTracker = 0;
		int excludedIndex = 0;

		// make the combinations by going through all the cards in order
		// make the excluded card the next one in the order
		// keep track of the cardIndex, so the next card will be the first in the next hand
		for (int i = 0; i < hand.Count; i++)
		{
			List<Card> newHand = new List<Card>();

			for (int j = 0; j < hand.Count - 1; j++)
			{
				int index = cardIndexTracker % hand.Count; // make sure the index does not go over 5
				cardIndexTracker++;
				newHand.Add(hand[index]);
				excludedIndex = (index + 1) % hand.Count; //excluded card will be next card after loop ends
			}

			hands.Add(new Hand(newHand, hand[excludedIndex]));
		}


		Console.WriteLine("*** Hand Combinations...");
		foreach (Hand h in hands)
		{
			h.printHand();
		}
		Console.WriteLine();

		return hands;
	}

	public static void printWin(List<Hand> hands)
	{
		sortHands(hands);
		Console.WriteLine(" --- HIGH HAND ORDER ---");
		foreach (Hand h in hands)
		{
			h.printWithLabel();
		}
		Console.WriteLine();
	}

	public static List<Card> processFile(string filename)
	{
		List<Card> hand = new List<Card>();
		bool duplicate = false;
		Card duplicateCard = null;

    // open file with stream reader (help from : https://stackoverflow.com/questions/7569904/easiest-way-to-read-from-and-write-to-files)
		using (StreamReader file = new StreamReader(filename))
		{
			string line = file.ReadLine();
			if (line != null)
			{
				string[] tokens = line.Split(',');
				foreach (string card in tokens)
				{
					string cardStr = card.Trim();
					string rank, suit;

					if (cardStr.Length == 3)
					{
						rank = cardStr.Substring(0, 2);
						suit = cardStr.Substring(2);
					}
					else
					{
						rank = cardStr.Substring(0, 1);
						suit = cardStr.Substring(1);
					}

					Card newCard = new Card(rank, suit);

					// check for duplicate
					foreach (Card c in hand)
					{
						if (newCard.equals(c))
						{
							duplicate = true;
							duplicateCard = c;
						}
					}

					hand.Add(newCard);
				}

				if (line.Substring(0, 2) == "10")
				{
					Console.WriteLine(line + "\n");
				}
				else
				{
					Console.WriteLine(" " + line + "\n");
				}
			}
		}

		if (duplicate)
		{
			Console.WriteLine("*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n");
			Console.WriteLine("*** DUPLICATE: " + duplicateCard.ToString() + " ***");
			Environment.Exit(1);
		}

		return hand;
	}

	public static bool highCardTieBreaker(Hand h1, Hand h2)
	{
		// check rank then suits 
		for (int i = h1.cards.Count - 1; i >= 0; i--)
		{
			if (h1.cards[i].rankValue() > h2.cards[i].rankValue())	
			{
				return false;
			}
			else if (h1.cards[i].rankValue() < h2.cards[i].rankValue())
			{
				return true;
			}
			else
			{
				if (h1.cards[i].suitValue() > h2.cards[i].suitValue())
					return false;
				else if (h1.cards[i].suitValue() < h2.cards[i].suitValue())
					return true;
			}
		}
		return false;
	}

	public static bool pairTieBreaker(Hand h1, Hand h2)
	{
		List<Card> pair1 = new List<Card>();
		List<Card> pair2 = new List<Card>();
		List<Card> other1 = new List<Card>();
		List<Card> other2 = new List<Card>();

		// store the pairs in the pair array lists and the other cards in the other array lists	
		foreach (Card c in h1.cards)
		{
			if (c.rankValue() == h1.highestCard.rankValue())
				pair1.Add(c);
			else
				other1.Add(c);
		}
		foreach (Card c in h2.cards)
		{
			if (c.rankValue() == h2.highestCard.rankValue())
				pair2.Add(c);
			else
				other2.Add(c);
		}

		// compare the pairs first (ranks then suits)
		for (int i = pair1.Count - 1; i >= 0; i--)
		{
			if (pair1[i].rankValue() > pair2[i].rankValue())
			{
				return false;
			}
			else if (pair1[i].rankValue() < pair2[i].rankValue())
			{
				return true;
			}
			else
			{
				if (pair1[i].suitValue() > pair2[i].suitValue())
					return false;
				if (pair1[i].suitValue() < pair2[i].suitValue())
					return true;
			}
		}

		// if pairs are the same, compare all the other cards (ranks then suits)
		for (int i = other1.Count - 1; i >= 0; i--)
		{
			if (other1[i].rankValue() > other2[i].rankValue())	
			{
				return false;
			}
			else if (other1[i].rankValue() < other2[i].rankValue())
			{
				return true;
			}
			else
			{
				if (other1[i].suitValue() > other2[i].suitValue())
					return false;
				if (other1[i].suitValue() < other2[i].suitValue())
					return true;
			}
		}
		return false;
	}

	public static bool threeTieBreaker(Hand h1, Hand h2)
	{
		List<Card> trip1 = new List<Card>();
		List<Card> trip2 = new List<Card>();
		List<Card> other1 = new List<Card>();
		List<Card> other2 = new List<Card>();

		// push the three of a kind into the trip vector
		foreach (Card c in h1.cards)
		{
			if (c.rankValue() == h1.highestCard.rankValue())
				trip1.Add(c);
			else
				other1.Add(c);
		}
		foreach (Card c in h2.cards)
		{
			if (c.rankValue() == h2.highestCard.rankValue())
				trip2.Add(c);
			else
				other2.Add(c);
		}

		// check the three of a kind rank and suit
		for (int i = trip1.Count - 1; i >= 0; i--)
		{
			if (trip1[i].rankValue() > trip2[i].rankValue())
			{
				return false;
			}
			else if (trip1[i].rankValue() < trip2[i].rankValue())
			{
				return true;
			}
			else
			{
				if (trip1[i].suitValue() > trip2[i].suitValue())
					return false;
				if (trip1[i].suitValue() < trip2[i].suitValue())
					return true;
			}
		}

		// check the other two cards rank and suit
		for (int i = other1.Count - 1; i >= 0; i--)
		{
			if (other1[i].rankValue() > other2[i].rankValue())
			{
				return false;
			}
			else if (other1[i].rankValue() < other2[i].rankValue())
			{
				return true;
			}
			else
			{
				if (other1[i].suitValue() > other2[i].suitValue())
					return false;
				if (other1[i].suitValue() < other2[i].suitValue())
					return true;
			}
		}

		return false;
	}

	public static bool fourTieBreaker(Hand h1, Hand h2)
	{
		// check the rank and suit of the card not in the four of a kind 
		// (all four of a kind tie breakers will have the same 4 cards)
		if (h1.highestCard.rankValue() > h2.highestCard.rankValue())
			return false;
		else if (h1.highestCard.rankValue() < h2.highestCard.rankValue())
			return true;
		else
		{
			if (h1.highestCard.suitValue() < h2.highestCard.suitValue())
				return true;
		}
		return false;
	}

	public static bool twoPairTieBreaker(Hand h1, Hand h2)
	{
		List<Card> pairs1 = new List<Card>();
		List<Card> pairs2 = new List<Card>();

		// (the kicker card has been stored as highest card for two pair)
		// add the kicker card in the first array pos bc it contains the least importance
		pairs1.Add(h1.highestCard);	
		pairs2.Add(h2.highestCard);

		// add the pairs to the list
		for (int i = 0; i < h1.cards.Count; i++)
		{
			if (!h1.cards[i].equals(h1.highestCard))
				pairs1.Add(h1.cards[i]);
			if (!h2.cards[i].equals(h2.highestCard))
				pairs2.Add(h2.cards[i]);
		}

		// compare the cards: rank then suit
		for (int i = pairs1.Count - 1; i >= 0; i--)
		{
			if (pairs1[i].rankValue() > pairs2[i].rankValue())
				return false;
			if (pairs1[i].rankValue() < pairs2[i].rankValue())
				return true;
			if (pairs1[i].suitValue() > pairs2[i].suitValue())
				return false;
			if (pairs1[i].suitValue() < pairs2[i].suitValue())
				return true;
		}
		return false;
	}

	public static bool straightTieBreaker(Hand h1, Hand h2)
	{
		// same as highCardTieBreaker bc straights will only differ in their highest card
		return highCardTieBreaker(h1, h2);
	}

	public static bool straightFlushTieBreaker(Hand h1, Hand h2)
	{
		// same as highCardTieBreaker bc straights will only differ in their highest card
		return highCardTieBreaker(h1, h2);
	}

	public static bool flushTieBreaker(Hand h1, Hand h2)
	{
		// same as highCardTieBreaker bc a six card hand can not produce two flushes of different suits
		return highCardTieBreaker(h1, h2);
	}

	public static bool fullHouseTieBreaker(Hand h1, Hand h2)
	{
		// same as three tieBreaker where you compare the three of a kind then the others (pairs in this case)
		return threeTieBreaker(h1, h2);
	}

	public static void swap(List<Hand> hands, int i)
	{
		Hand tmp = hands[i + 1];
		hands[i + 1] = hands[i];
		hands[i] = tmp;
	}

	public static void sortHands(List<Hand> hands)
	{
		bool swapped;
		do
		{
			swapped = false;
			for (int i = 0; i < hands.Count - 1; i++)
			{
				Hand h1 = hands[i];
				Hand h2 = hands[i + 1];

				// sort hands based on handvalue
				if (h1.handValue < h2.handValue)
				{
					var temp = hands[i];
					hands[i] = hands[i + 1];
					hands[i + 1] = temp;
					swapped = true;
				}
				else if (h1.handValue == h2.handValue)
				{
					bool needSwap = false;

					if (h1.label == "High Card" && h2.label == "High Card")
						needSwap = highCardTieBreaker(h1, h2);
					else if (h1.label == "Pair" && h2.label == "Pair")
						needSwap = pairTieBreaker(h1, h2);
					else if (h1.label == "Four of a Kind" && h2.label == "Four of a Kind")
						needSwap = fourTieBreaker(h1, h2);
					else if (h1.label == "Three of a Kind" && h2.label == "Three of a Kind")
						needSwap = threeTieBreaker(h1, h2);
					else if (h1.label == "Full House" && h2.label == "Full House")
						needSwap = fullHouseTieBreaker(h1, h2);
					else if (h1.label == "Straight Flush" && h2.label == "Straight Flush")
						needSwap = straightFlushTieBreaker(h1, h2);
					else if (h1.label == "Flush" && h2.label == "Flush")
						needSwap = flushTieBreaker(h1, h2);
					else if (h1.label == "Straight" && h2.label == "Straight")
						needSwap = straightTieBreaker(h1, h2);
					else if (h1.label == "Two Pair" && h2.label == "Two Pair")
						needSwap = twoPairTieBreaker(h1, h2);

					// perform swap
					if (needSwap)
					{
						swap(hands, i);
						swapped = true;
					}
				}
			}
		} while (swapped);
	}
}
