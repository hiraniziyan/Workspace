#ifndef HAND_H
#define HAND_H

#include <iostream>
#include <vector>
#include <string>
#include "card.h"

using namespace std;

class Hand
{
	public:
		Hand(vector<Card> c, Card e);
		void toString();
		void printWithLabel();
		void findWin();
		void bubbleSortCards();
		bool isFlush();
		bool isStraight();
		bool checkPair();
		bool checkThree();
		bool checkFour();
		bool checkTwoPair();
		bool checkFullHouse();
		bool operator<(const Hand& other) const;

		int handValue;
		string label;
		Card highestCard;
		vector<Card> cards;
		vector<Card> originalOrder;
		Card excluded;
};

#endif

