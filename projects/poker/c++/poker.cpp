#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <random>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include "card.h"
#include "hand.h"

using namespace std;

vector<Card> generateDeck();
void printHand(vector<Card> hand);
vector<Hand> generateCombinations(vector<Card> hand);
void printWin(vector<Hand> hands);
vector<Card> processFile(const string& filename);
bool highCardTieBreaker(Hand& h1, Hand& h2);
void sortHands(vector<Hand>& hands);
bool pairTieBreaker(Hand& h1, Hand& h2);
bool fourTieBreaker(Hand& h1, Hand& h2);
bool threeTieBreaker(Hand &h1, Hand& h2);
bool straightFlushTieBreaker(Hand& h1, Hand& h2);
bool straightTieBreaker(Hand& h1, Hand& h2);
bool fullHouseTieBreaker(Hand& h1, Hand& h2);
bool flushTieBreaker(Hand& h1, Hand& h2);

int main(int argc, char* argv[])
{
	cout << "\n*** P O K E R  H A N D  A N A L Y Z E R ***\n\n\n";

	vector<Card> hand;	// vector to hold the 6 card hand

	if (argc == 1)
	{
		cout << "*** USING RANDOMIZED DECK OF CARDS ***\n";
		hand = generateDeck();	// generates the decks and returns the 6 card hand
	}
	if (argc == 2)
	{
		string filename = argv[1];	
		cout << "*** USING TEST DECK ***\n\n";
		cout << "*** File: " << filename << endl;
		hand = processFile(filename);	
	}

	if (argc == 1)
	{
		cout << "*** Here is the hand\n";
		printHand(hand);	// print the 6 card hand
	}

	vector<Hand> hands = generateCombinations(hand);

	printWin(hands);

	return 0;
}

vector<Card> generateDeck()
{
	
	vector<string> suits = {"D","C","H","S"};
	vector<string> ranks = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"};
	vector<Card> allCards;

	// generate all 52 cards
	for (string suit : suits)
	{
		for (string rank : ranks)
		{
			allCards.push_back(Card(rank, suit));
		}
	}

	vector<Card> deck(52); // vector to hold 52 cards randomized

	srand(time(0)); // seed the random number generator at current time

	// assign each card to a place in the deck
	for (Card c : allCards)	
	{
		int pos = rand() % 52;	// get the position it should be in

		while (!deck[pos].rank.empty())	// fill the deck vector based on empty positions
		{
			pos = (pos + 1) % 52;
		}
		deck[pos] = c;	
	}

	// print the shuffled 52 card deck
	cout << "\n*** Shuffled 52 card deck:\n";
	for (int i = 0; i < deck.size(); i++)
	{
		cout << deck[i].toString() << " ";
		if ((i+1) % 13 == 0)
			cout << "\n";
	}
	cout << endl;

	// get the first six cards in the shuffled deck
	vector<Card> hand;
	for (int i = 0; i < 6; i++)
		hand.push_back(deck[i]);

	return hand;
}

void printHand(vector<Card> hand)
{
	// prints each card in the six card hand
	cout << " ";
	for (Card card : hand)
		cout << card.toString() << " ";
	cout << "\n\n";
}

vector<Hand> generateCombinations(vector<Card> hand)
{
	vector<Hand> hands;

	int cardIndexTracker = 0;
	int excludedIndex = 0;

	// make the combinations by going through all the cards in order
	// make the excluded card the next one in the order
	// keep track of the cardIndex, so the next card will be the first in the next hand
	for (int i = 0; i < hand.size(); i++)
	{
		vector<Card> newHand;
		for (int j = 0; j < hand.size() - 1; j++)
		{
			int index = cardIndexTracker % hand.size();	// make sure the index does not go over 5
			cardIndexTracker++;		
			newHand.push_back(hand[index]);	
			excludedIndex = (index + 1) % hand.size(); //excluded card will be the next card after the loop ends
		}
		
		hands.push_back(Hand(newHand, hand[excludedIndex]));
		
	}

	cout << "*** Hand Combinations...\n";
	for (Hand currHand : hands)
	{
		currHand.toString();
	}
	cout << endl;

	return hands;
}

void printWin(vector<Hand> hands)
{
	sortHands(hands);
	cout << " --- HIGH HAND ORDER ---\n";
	for (Hand hand : hands)
		hand.printWithLabel();
	cout << endl;
}

vector<Card> processFile(const string& filename)
{
	ifstream file(filename);	
	vector<Card> hand;
	string line;
	bool duplicate = false;
	Card duplicateCard;

	if (getline(file, line)) 
	{
		stringstream ss(line);	
		string cardStr;

		while (getline(ss, cardStr, ',')) // split on comma
		{
			// trim leading/trailing spaces
			cardStr.erase(0, cardStr.find_first_not_of(' '));
			cardStr.erase(cardStr.find_last_not_of(' ') + 1);

			string rank, suit;
			if (cardStr.size() == 3)	// case for "10" 
			{
				rank = cardStr.substr(0, 2);
				suit = cardStr.substr(2, 1);
			}
			else if (cardStr.size() == 2) 
			{
				rank = cardStr.substr(0, 1);
				suit = cardStr.substr(1, 1);
			}
			Card newCard = Card(rank,suit);
			for (Card c : hand)
			{
				if (newCard == c)
				{
					duplicate = true;
					duplicateCard = c;		
				}
			}
			hand.push_back(newCard);
		}
	}
	
	if (line.substr(0, 2) == "10")
		cout << line << endl << endl;
	else
		cout << " " << line << endl << endl;
	
	if (duplicate)
	{
		cout << "*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n\n";
		cout << "*** DUPLICATE: " + duplicateCard.toString() + " ***\n";
		exit(1);
	}
	return hand;
}


bool twoPairTieBreaker(Hand& h1, Hand& h2)
{
	vector<Card> pairs1;
	vector<Card> pairs2;
	
	// highest card is the kicker card
	// push it to the front to compare last
	pairs1.push_back(h1.highestCard); 
	pairs2.push_back(h2.highestCard);

	// push the pairs into vector
	for (int i = 0; i < h1.cards.size(); i++)
	{
		if (!(h1.cards[i] == h1.highestCard))
			pairs1.push_back(h1.cards[i]);

		if (!(h2.cards[i] == h2.highestCard))
			pairs2.push_back(h2.cards[i]);
	}

	// compare ranks then suits 
	for (int i = pairs1.size() - 1; i >= 0; i--)
	{
		if (pairs1[i].rankValue() > pairs2[i].rankValue())
			return false;
		if (pairs1[i].rankValue() < pairs2[i].rankValue())
		{
			swap(h1,h2);
			return true;
		}
		if (pairs1[i].suitValue() > pairs2[i].suitValue())
			return false;
		if (pairs1[i].suitValue() < pairs2[i].suitValue())
		{
			swap(h1, h2);
			return true;
		}
	}

	
	return false;

}

bool highCardTieBreaker(Hand& h1, Hand& h2)
{
	// compare the cards rank and suit from back to front
	for (int i = h1.cards.size() - 1; i >= 0; i--)
	{
		if (h1.cards[i].rankValue() > h2.cards[i].rankValue())
		{
			return false;
		}
		else if (h1.cards[i].rankValue() < h2.cards[i].rankValue())
		{
			swap(h1, h2);
			return true;
		}
		else
		{
			if (h1.cards[i].suitValue() > h2.cards[i].suitValue())
			{
				return false;
			}
			else if (h1.cards[i].suitValue() < h2.cards[i].suitValue())
			{
				swap(h1, h2);
				return true;
			}
		}
	}
	return false;
}

bool threeTieBreaker(Hand& h1, Hand& h2)
{
	vector<Card> trip1;
	vector<Card> trip2;
	vector<Card> other1;
	vector<Card> other2;

	// push the three of a kind into the trip vector
	for (int i = 0; i < h1.cards.size(); i++)
	{
		if (h1.cards[i].rankValue() == h1.highestCard.rankValue())
			trip1.push_back(h1.cards[i]);
		else
			other1.push_back(h1.cards[i]);

		if (h2.cards[i].rankValue() == h2.highestCard.rankValue())
                        trip2.push_back(h2.cards[i]);
                else
                        other2.push_back(h2.cards[i]);

	}

	// check the three of a kind rank and suit
	for (int i = trip1.size() - 1; i >= 0; i--)
	{
		if (trip1[i].rankValue() > trip2[i].rankValue())
			return false;
		else if(trip1[i].rankValue() < trip2[i].rankValue())
		{
			swap(h1,h2);
			return true;
		}
		else
		{	
			if (trip1[i].suitValue() > trip2[i].suitValue())
				return false;
			if(trip1[i].suitValue() < trip2[i].suitValue())
			{
				swap(h1, h2);
				return true;
			}
		}
	}

	// check the other two cards rank and suit
	for (int i = other1.size() - 1; i >= 0; i--)
	{
		if (other1[i].rankValue() > other2[i].rankValue())
                        return false;
                else if(other1[i].rankValue() < other2[i].rankValue())
                {
                        swap(h1,h2);
                        return true;
                }
                else
                {
                        if (other1[i].suitValue() > other2[i].suitValue())
                                return false;
                        if(other1[i].suitValue() < other2[i].suitValue())
                        {
                                swap(h1, h2);
                                return true;
                        }
                }
	}
	return false;
}

bool fourTieBreaker(Hand& h1, Hand& h2)
{
	// highest card for four of a kind contains the kicker card, 
	// only have to evaluate the rank and suit of kicker card because four kind will always be same
	
	if (h1.highestCard.rankValue() > h2.highestCard.rankValue())
		return false;
	else if (h1.highestCard.rankValue() < h2.highestCard.rankValue())
	{
		swap(h1,h2);
		return true;
	}
	else
	{
		if (h1.highestCard.suitValue() < h2.highestCard.suitValue())
		{
			swap(h1,h2);
			return true;
		}
	}
	return false;
}	

bool pairTieBreaker(Hand &h1, Hand& h2)
{
	vector<Card> pair1;
	vector<Card> pair2;
	vector<Card> other1;
	vector<Card> other2;
	
	// add the pair into the pair array and other cards into other array
	for (int i = 0; i < h1.cards.size(); i++)
	{
		if (h1.cards[i].rankValue() == h1.highestCard.rankValue())
			pair1.push_back(h1.cards[i]);
		else
			other1.push_back(h1.cards[i]);

		if (h2.cards[i].rankValue() == h2.highestCard.rankValue())
                        pair2.push_back(h2.cards[i]);
                else
                        other2.push_back(h2.cards[i]);

	}

	// compare suit and rank of pair first
	for (int i = pair1.size() - 1; i >= 0; i--)
	{
		if (pair1[i].rankValue() > pair2[i].rankValue())
			return false;
		else if(pair1[i].rankValue() < pair2[i].rankValue())
		{
			swap(h1,h2);
			return true;
		}
		else
		{	
			if (pair1[i].suitValue() > pair2[i].suitValue())
				return false;
			if(pair1[i].suitValue() < pair2[i].suitValue())
			{
				swap(h1, h2);
				return true;
			}
		}
	}

	//compare suit and rank of other three cards
	for (int i = other1.size() - 1; i >= 0; i--)
	{
		if (other1[i].rankValue() > other2[i].rankValue())
                        return false;
                else if(other1[i].rankValue() < other2[i].rankValue())
                {
                        swap(h1,h2);
                        return true;
                }
                else
                {
                        if (other1[i].suitValue() > other2[i].suitValue())
                                return false;
                        if(other1[i].suitValue() < other2[i].suitValue())
                        {
                                swap(h1, h2);
                                return true;
                        }
                }
	}
	return false;
}

bool straightTieBreaker(Hand& h1, Hand& h2)
{
	// only one card will be different in straight tie breaker, so we can just do highCardTieBreaker
	return highCardTieBreaker(h1, h2);
}

bool straightFlushTieBreaker(Hand& h1, Hand& h2)
{
	// only one card will be different in straight flush tie breaker, so we can just do highCardTieBreaker
	return highCardTieBreaker(h1, h2);
}

bool flushTieBreaker(Hand& h1, Hand& h2)
{
	// only one card will be different in flush tie breaker, so we can just do highCardTieBreaker
	return highCardTieBreaker(h1, h2);
}

bool fullHouseTieBreaker(Hand& h1, Hand& h2)
{
	// same logic as three of a kind, with others1 and others2 being the pairs
	return threeTieBreaker(h1, h2);
}

void sortHands(vector<Hand>& hands) // bubble sort algorithm
{
	bool swapped;
	bool didSwap;

	do
	{
		swapped = false;

		for (int i = 0; i < hands.size() - 1; i++)
		{
			if (hands[i].handValue < hands[i+1].handValue)
			{
				swap(hands[i], hands[i+1]);
				swapped = true;
			}
			else if (hands[i].handValue == hands[i+1].handValue)
			{
				if (hands[i].label == "High Card" && hands[i+1].label == "High Card")
					didSwap = highCardTieBreaker(hands[i], hands[i+1]);

				else if (hands[i].label == "Pair" && hands[i+1].label == "Pair")
					didSwap = pairTieBreaker(hands[i], hands[i+1]);

				else if (hands[i].label == "Four of a Kind" && hands[i+1].label == "Four of a Kind")
					didSwap = fourTieBreaker(hands[i], hands[i+1]);

				else if (hands[i].label == "Three of a Kind" && hands[i+1].label == "Three of a Kind")
					didSwap = threeTieBreaker(hands[i], hands[i+1]);

				else if (hands[i].label == "Full House" && hands[i+1].label == "Full House")
					didSwap = fullHouseTieBreaker(hands[i], hands[i+1]);

				else if (hands[i].label == "Straight Flush" && hands[i+1].label == "Straight Flush")
					didSwap = straightFlushTieBreaker(hands[i], hands[i+1]);

				else if (hands[i].label == "Flush" && hands[i+1].label == "Flush")
					didSwap = flushTieBreaker(hands[i], hands[i+1]);
	
				else if (hands[i].label == "Straight" && hands[i+1].label == "Straight")
					didSwap = straightTieBreaker(hands[i], hands[i+1]);
				
				else if (hands[i].label == "Two Pair" && hands[i+1].label == "Two Pair")
					didSwap = twoPairTieBreaker(hands[i], hands[i+1]);

				if (didSwap)
					swapped = true;
			}
		}
	} while (swapped);
}

