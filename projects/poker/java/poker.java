import java.util.*;
import java.io.*;

public class poker
{

	public static void main(String[] args) throws java.io.FileNotFoundException
	{
		System.out.println("\n*** P O K E R  H A N D  A N A L Y Z E R ***\n\n");

		List<Card> hand = new ArrayList<>();

		if (args.length == 0)
		{
			System.out.println("*** USING RANDOMIZED DECK OF CARDS ***");
			hand = generateDeck();	// get the six card hand
		}
		if (args.length == 1)
		{
			String filename = args[0];
			System.out.println("*** USING TEST DECK ***\n");
			System.out.println("*** File: " + filename);
			hand = processFile(filename);	// get the six card hand
		}

		if (args.length == 0)
		{
			System.out.println("*** Here is the hand");
			printHand(hand);
		}

		List<Hand> hands = generateCombinations(hand);	
		printWin(hands);
	}

	public static List<Card> generateDeck()
	{
		String[] suits = {"D","C","H","S"};
		String[] ranks = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"};
		List<Card> allCards = new ArrayList<>();

		// generate 52 card deck
		for (String s : suits)
		{
			for (String r : ranks)
			{
				allCards.add(new Card(r, s));
			}
		}

		Card[] deck = new Card[52];
		Random rand = new Random();

		// randomize deck and store card in non filled positions
		for (Card c : allCards)
		{
			int pos = rand.nextInt(52);
			while (deck[pos] != null)
			{
				pos = (pos + 1) % 52;
			}
			deck[pos] = c;
		}

		System.out.println("\n*** Shuffled 52 card deck:");
		for (int i = 0; i < deck.length; i++)
		{
			System.out.print(deck[i].toString() + " ");
			if ((i + 1) % 13 == 0)
				System.out.println();
		}
		System.out.println();

		List<Card> sixCardHand = new ArrayList<>();

		for (int i = 0; i < 6; i++)
			sixCardHand.add(deck[i]);
		return sixCardHand;
	}

	public static void printHand(List<Card> hand)
	{
		System.out.print(" ");
		for (Card c : hand)
			System.out.print(c.toString() + " ");
		System.out.println("\n");
	}

	public static List<Hand> generateCombinations(List<Card> hand)
	{
		List<Hand> hands = new ArrayList<>();

		int cardIndexTracker = 0;
		int excludedIndex = 0;


		// make the combinations by going through all the cards in order
		// make the excluded card the next one in the order
		// keep track of the cardIndex, so the next card will be the first in the next hand
		for (int i = 0; i < hand.size(); i++) {
			List<Card> newHand = new ArrayList<>();

			for (int j = 0; j < hand.size() - 1; j++) {
				int index = cardIndexTracker % hand.size(); // make sure index does not go over 5
				cardIndexTracker++;
				newHand.add(hand.get(index));
				excludedIndex = (index + 1) % hand.size(); // excluded card will be next one after loop
			}

			hands.add(new Hand(newHand, hand.get(excludedIndex)));
		}


		System.out.println("*** Hand Combinations...");
		for (Hand h : hands) 
			h.printHand();
		System.out.println();

		return hands;
	}

	public static void printWin(List<Hand> hands)
	{
		sortHands(hands);
		System.out.println(" --- HIGH HAND ORDER ---");
		for (Hand h : hands)
		{ 
			h.printWithLabel();
		}
		System.out.println();
	}

	public static List<Card> processFile(String filename) throws java.io.FileNotFoundException
	{
		List<Card> hand = new ArrayList<>();
		boolean duplicate = false;
		Card duplicateCard = null;
		
		// declare scanner to read file
		Scanner scanner = new Scanner(new File(filename));
		if (scanner.hasNextLine())
		{
			String line = scanner.nextLine();
			String[] tokens = line.split(",");
			for (String token : tokens)
			{
				String cardStr = token.trim();
				String rank, suit;

				if (cardStr.length() == 3)  
				{
					rank = cardStr.substring(0, 2);
					suit = cardStr.substring(2);
				}
				else  
				{
					rank = cardStr.substring(0, 1);
					suit = cardStr.substring(1);
				}

				Card newCard = new Card(rank, suit);
				
				// check for duplicate
				for (Card c : hand)
				{
					if (newCard.equals(c))
					{
						duplicate = true;
						duplicateCard = c;
					}
				}

				hand.add(newCard);
			}
			if (line.substring(0, 2).equals("10")) {
				System.out.println(line + "\n");
			} else {
				System.out.println(" " + line + "\n");
			}
		}
		scanner.close();

		if (duplicate)
		{
			System.out.println("*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n");
			System.out.println("*** DUPLICATE: " + duplicateCard.toString() + " ***");
			System.exit(1);
		}

		return hand;
	}

	public static boolean highCardTieBreaker(Hand h1, Hand h2)
	{
		for (int i = h1.cards.size() - 1; i >= 0; i--)
		{
			// check rank value first
			if (h1.cards.get(i).rankValue() > h2.cards.get(i).rankValue())
				return false;
			else if (h1.cards.get(i).rankValue() < h2.cards.get(i).rankValue())
			{
				return true;
			}
			else
			{
				// check suits if rank is the same
				if (h1.cards.get(i).suitValue() > h2.cards.get(i).suitValue())
					return false;
				else if (h1.cards.get(i).suitValue() < h2.cards.get(i).suitValue())
				{
					return true;
				}
			}
		}
		return false;
	}

	public static boolean pairTieBreaker(Hand h1, Hand h2)
	{
		List<Card> pair1 = new ArrayList<>();
		List<Card> pair2 = new ArrayList<>();
		List<Card> other1 = new ArrayList<>();
		List<Card> other2 = new ArrayList<>();

		// store the pairs in the pair array lists and the other cards in the other array lists
		for (Card c : h1.cards)
		{
			if (c.rankValue() == h1.highestCard.rankValue())
				pair1.add(c);
			else
				other1.add(c);
		}
		for (Card c : h2.cards)
		{
			if (c.rankValue() == h2.highestCard.rankValue())
				pair2.add(c);
			else
				other2.add(c);
		}

		// compare the pairs first (ranks then suits)
		for (int i = pair1.size() - 1; i >= 0; i--)
		{
			if (pair1.get(i).rankValue() > pair2.get(i).rankValue())
				return false;
			else if (pair1.get(i).rankValue() < pair2.get(i).rankValue())
			{
				return true;
			}
			else
			{
				if (pair1.get(i).suitValue() > pair2.get(i).suitValue())
					return false;
				if (pair1.get(i).suitValue() < pair2.get(i).suitValue())
				{
					return true;
				}
			}
		}

		// if pairs are the same, compare all the other cards (ranks then suits)
		for (int i = other1.size() - 1; i >= 0; i--)
		{
			if (other1.get(i).rankValue() > other2.get(i).rankValue())
				return false;
			else if (other1.get(i).rankValue() < other2.get(i).rankValue())
			{
				return true;
			}
			else
			{
				if (other1.get(i).suitValue() > other2.get(i).suitValue())
					return false;
				if (other1.get(i).suitValue() < other2.get(i).suitValue())
				{
					return true;
				}
			}
		}
		return false;
	}

	public static boolean threeTieBreaker(Hand h1, Hand h2)
	{
		List<Card> trip1 = new ArrayList<>();
		List<Card> trip2 = new ArrayList<>();
		List<Card> other1 = new ArrayList<>();
		List<Card> other2 = new ArrayList<>();

		// push the three of a kind into the trip vector
		for (Card c : h1.cards)
		{
			if (c.rankValue() == h1.highestCard.rankValue())
				trip1.add(c);
			else
				other1.add(c);
		}
		for (Card c : h2.cards)
		{
			if (c.rankValue() == h2.highestCard.rankValue())
				trip2.add(c);
			else
				other2.add(c);
		}
		
		// check the three of a kind rank and suit
		for (int i = trip1.size() - 1; i >= 0; i--)
		{
			if (trip1.get(i).rankValue() > trip2.get(i).rankValue())
				return false;
			else if (trip1.get(i).rankValue() < trip2.get(i).rankValue())
			{
				return true;
			}
			else
			{
				if (trip1.get(i).suitValue() > trip2.get(i).suitValue())
					return false;
				if (trip1.get(i).suitValue() < trip2.get(i).suitValue())
				{
					return true;
				}
			}
		}

		// check the other two cards rank and suit
		for (int i = other1.size() - 1; i >= 0; i--)
		{
			if (other1.get(i).rankValue() > other2.get(i).rankValue())
				return false;
			else if (other1.get(i).rankValue() < other2.get(i).rankValue())
			{
				return true;
			}
			else
			{
				if (other1.get(i).suitValue() > other2.get(i).suitValue())
					return false;
				if (other1.get(i).suitValue() < other2.get(i).suitValue())
				{
					return true;
				}
			}
		}

		return false;
	}

	public static boolean fourTieBreaker(Hand h1, Hand h2)
	{
		// check the rank and suit of the card not in the four of a kind 
		// (all four of a kind tie breakers will have the same 4 cards)
		if (h1.highestCard.rankValue() > h2.highestCard.rankValue())
			return false;
		else if (h1.highestCard.rankValue() < h2.highestCard.rankValue())
		{
			return true;
		}
		else
		{
			if (h1.highestCard.suitValue() < h2.highestCard.suitValue())
			{
				return true;
			}
		}
		return false;
	}

	public static boolean twoPairTieBreaker(Hand h1, Hand h2)
	{
		List<Card> pairs1 = new ArrayList<>();
		List<Card> pairs2 = new ArrayList<>();
		
		// (the kicker card has been stored as highest card for two pair)
		pairs1.add(h1.highestCard);	// add the kicker card in the first array pos bc it contains the least importance
		pairs2.add(h2.highestCard);

		// add the pairs to the list 
		for (int i = 0; i < h1.cards.size(); i++)
		{
			if (!h1.cards.get(i).equals(h1.highestCard))
				pairs1.add(h1.cards.get(i));
			if (!h2.cards.get(i).equals(h2.highestCard))
				pairs2.add(h2.cards.get(i));
		}

		// compare the cards: rank then suit
		for (int i = pairs1.size() - 1; i >= 0; i--)
		{
			if (pairs1.get(i).rankValue() > pairs2.get(i).rankValue())
				return false;
			if (pairs1.get(i).rankValue() < pairs2.get(i).rankValue())
			{
				return true;
			}
			if (pairs1.get(i).suitValue() > pairs2.get(i).suitValue())
				return false;
			if (pairs1.get(i).suitValue() < pairs2.get(i).suitValue())
			{
				return true;
			}
		}
		return false;
	}

	public static boolean straightTieBreaker(Hand h1, Hand h2)
	{
		// same as highCardTieBreaker bc straights will only differ in their highest card
		return highCardTieBreaker(h1, h2);
	}

	public static boolean straightFlushTieBreaker(Hand h1, Hand h2)
	{
		// same as highCardTieBreaker bc straights will only differ in their highest card
		return highCardTieBreaker(h1, h2);
	}

	public static boolean flushTieBreaker(Hand h1, Hand h2)
	{
		// same as highCardTieBreaker bc a six card hand can not produce two flushes of different suits
		return highCardTieBreaker(h1, h2);
	}

	public static boolean fullHouseTieBreaker(Hand h1, Hand h2)
	{
		// same as three tieBreaker where you compare the three of a kind then the others (pairs in this case)
		return threeTieBreaker(h1, h2);
	}

	public static void swap(List<Hand> hands, int i)
	{	
		Hand tmp = hands.get(i+1);
		hands.set(i+1, hands.get(i));
		hands.set(i, tmp);
	}

	public static void sortHands(List<Hand> hands)
	{
		// bubble sort for sorting hands
		boolean swapped;
		do
		{
			swapped = false;
			for (int i = 0; i < hands.size() - 1; i++)
			{
				Hand h1 = hands.get(i);
				Hand h2 = hands.get(i + 1);
				
				// sort the hands based on the hand value
				if (h1.handValue < h2.handValue)
				{
					Collections.swap(hands, i, i + 1);
					swapped = true;
				}
				else if (h1.handValue == h2.handValue) // tie
				{
					boolean needSwap = false;	
					
					// call appropriate tieBreaker methods
					if (h1.label.equals("High Card") && h2.label.equals("High Card"))
						needSwap = highCardTieBreaker(h1, h2);
					else if (h1.label.equals("Pair") && h2.label.equals("Pair"))
						needSwap = pairTieBreaker(h1, h2);
					else if (h1.label.equals("Four of a Kind") && h2.label.equals("Four of a Kind"))
						needSwap = fourTieBreaker(h1, h2);
					else if (h1.label.equals("Three of a Kind") && h2.label.equals("Three of a Kind"))
						needSwap = threeTieBreaker(h1, h2);
					else if (h1.label.equals("Full House") && h2.label.equals("Full House"))
						needSwap = fullHouseTieBreaker(h1, h2);
					else if (h1.label.equals("Straight Flush") && h2.label.equals("Straight Flush"))
						needSwap = straightFlushTieBreaker(h1, h2);
					else if (h1.label.equals("Flush") && h2.label.equals("Flush"))
						needSwap = flushTieBreaker(h1, h2);
					else if (h1.label.equals("Straight") && h2.label.equals("Straight"))
						needSwap = straightTieBreaker(h1, h2);
					else if (h1.label.equals("Two Pair") && h2.label.equals("Two Pair"))
						needSwap = twoPairTieBreaker(h1, h2);

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
