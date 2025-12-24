package main

import (
	"fmt"
)

type Hand struct {
	handValue int
	label string
	highestCard *Card
	cards []*Card
	originalOrder []*Card
	excluded *Card
}

func NewHand(c []*Card, e *Card) *Hand {
	h := &Hand{
		cards: append([]*Card{}, c...),
		excluded: e,
		originalOrder: append([]*Card{}, c...),
	}
	h.findWin()
	return h
}

func (h *Hand) printHand() {
	// print cards in correct format
	for i := 0; i < len(h.originalOrder); i++ {
		c := h.originalOrder[i]
		fmt.Printf("%2s%-2s", c.rank, c.suit)
	}
	fmt.Printf("| %2s%-2s\n", h.excluded.rank, h.excluded.suit)
}

func (h *Hand) printWithLabel() {
	// print cards with win label
	for i := len(h.cards) - 1; i >= 0; i-- {
		c := h.cards[i]
		fmt.Printf("%2s%-2s", c.rank, c.suit)
	}
	fmt.Printf("| %2s%-2s-- %s\n", h.excluded.rank, h.excluded.suit, h.label)
}

func (h *Hand) lessThan(otherHand *Hand) bool {
	return h.handValue < otherHand.handValue
}

func (h *Hand) bubbleSortCards() {
	// bubble sort from least to greatest
	for i := 0; i < len(h.cards); i++ {
		for j := 0; j < len(h.cards)-i-1; j++ {
			if h.cards[j].rankValue() > h.cards[j+1].rankValue() ||
				(h.cards[j].rankValue() == h.cards[j+1].rankValue() &&
					h.cards[j].suitValue() > h.cards[j+1].suitValue()) {
				h.cards[j], h.cards[j+1] = h.cards[j+1], h.cards[j]
			}
		}
	}
}

func (h *Hand) isFlush() bool {
	// checks if all suits are the same as the suit of the card before
	for i := 0; i < len(h.cards)-1; i++ {
		if h.cards[i].suit != h.cards[i+1].suit {
			return false
		}
	}
	h.label = "Flush"
	h.handValue = 6
	h.highestCard = h.cards[4]
	return true
}

func (h *Hand) isStraight() bool {
	// check manually for ace low straight
	if h.cards[0].rankValue() == 2 && h.cards[1].rankValue() == 3 && h.cards[2].rankValue() == 4 &&
		h.cards[3].rankValue() == 5 && h.cards[4].rankValue() == 14 {
		h.label = "Straight"
		h.handValue = 5
		h.highestCard = h.cards[3]
		return true
	}

	for i := 0; i < len(h.cards)-1; i++ {
		if h.cards[i].rankValue()+1 != h.cards[i+1].rankValue() {
			return false
		}
	}
	h.label = "Straight"
	h.handValue = 5
	if h.cards[4].rankValue() == 14 {
		h.highestCard = h.cards[3]
	} else {
		h.highestCard = h.cards[4]
	}
	return true
}

func (h *Hand) checkPair() bool {
	// checks if next card has the same rank value as current because cards are already sorted
	for i := 0; i < len(h.cards)-1; i++ {
		if h.cards[i].rankValue() == h.cards[i+1].rankValue() {
			h.label = "Pair"
			h.handValue = 2
			h.highestCard = h.cards[i+1]
			return true
		}
	}
	return false
}

func (h *Hand) checkThree() bool {
	// checks all three combinations manually and assigns field values (highest card == last card in the three of a kind)
	if h.cards[0].rankValue() == h.cards[1].rankValue() && h.cards[1].rankValue() == h.cards[2].rankValue() {
		h.label = "Three of a Kind"
		h.handValue = 4
		h.highestCard = h.cards[2]
		return true
	}
	if h.cards[1].rankValue() == h.cards[2].rankValue() && h.cards[2].rankValue() == h.cards[3].rankValue() {
		h.label = "Three of a Kind"
		h.handValue = 4
		h.highestCard = h.cards[3]
		return true
	}
	if h.cards[2].rankValue() == h.cards[3].rankValue() && h.cards[3].rankValue() == h.cards[4].rankValue() {
		h.label = "Three of a Kind"
		h.handValue = 4
		h.highestCard = h.cards[4]
		return true
	}
	return false
}

func (h *Hand) checkFour() bool {
	// checks both combinations manually and assigns field values
	if h.cards[0].rankValue() == h.cards[1].rankValue() &&
		h.cards[1].rankValue() == h.cards[2].rankValue() &&
		h.cards[2].rankValue() == h.cards[3].rankValue() {
		h.label = "Four of a Kind"
		h.handValue = 8
		h.highestCard = h.cards[4]
		return true
	}
	if h.cards[1].rankValue() == h.cards[2].rankValue() &&
		h.cards[2].rankValue() == h.cards[3].rankValue() &&
		h.cards[3].rankValue() == h.cards[4].rankValue() {
		h.label = "Four of a Kind"
		h.handValue = 8
		h.highestCard = h.cards[0]
		return true
	}
	return false
}

func (h *Hand) checkFullHouse() bool {
	// check the three pair and then the two pair for both possible combinations
	if h.cards[0].rankValue() == h.cards[1].rankValue() && h.cards[1].rankValue() == h.cards[2].rankValue() {
		if h.cards[3].rankValue() == h.cards[4].rankValue() {
			h.label = "Full House"
			h.handValue = 7
			h.highestCard = h.cards[2]
			return true
		}
	} else if h.cards[2].rankValue() == h.cards[3].rankValue() && h.cards[3].rankValue() == h.cards[4].rankValue() {
		if h.cards[0].rankValue() == h.cards[1].rankValue() {
			h.label = "Full House"
			h.handValue = 7
			h.highestCard = h.cards[4]
			return true
		}
	}
	return false
}

func (h *Hand) checkTwoPair() bool {
	hasOnePair := false
	kickerCardPos := -1

	for i := 0; i < len(h.cards)-1; i++ {
		if h.cards[i].rankValue() == h.cards[i+1].rankValue() {
			if !hasOnePair {
				hasOnePair = true
			} else {
				h.label = "Two Pair"
				h.handValue = 3
				if kickerCardPos != -1 {
					h.highestCard = h.cards[kickerCardPos]
				} else {
					h.highestCard = h.cards[4]
				}
				return true
			}
			i++
		} else {
			kickerCardPos = i
		}
	}
	return false
}

func (h *Hand) findWin() {
	h.bubbleSortCards()

	if h.isStraight() && h.isFlush() {
		if h.cards[4].rankValue() == 14 && h.cards[3].rankValue() == 13 {
			h.label = "Royal Straight Flush"
			h.handValue = 10
			h.highestCard = h.cards[4]
		} else {
			h.label = "Straight Flush"
			h.handValue = 9
			h.highestCard = h.cards[4]
			if h.cards[4].rankValue() == 14 && h.cards[0].rankValue() == 2 {
				ace := h.cards[4]
				for i := 4; i > 0; i-- {
					h.cards[i] = h.cards[i-1]
				}
				h.cards[0] = ace
			}
		}
		return
	}

	if h.checkFour() {
		return
	}
	if h.checkFullHouse() {
		return
	}
	if h.isFlush() {
		return
	}
	if h.isStraight() {
		if h.cards[4].rankValue() == 14 && h.cards[0].rankValue() == 2 {
			ace := h.cards[4]
			for i := 4; i > 0; i-- {
				h.cards[i] = h.cards[i-1]
			}
			h.cards[0] = ace
		}
		return
	}
	if h.checkThree() {
		return
	}
	if h.checkTwoPair() {
		return
	}
	if h.checkPair() {
		return
	}

	h.label = "High Card"
	h.handValue = 1
	h.highestCard = h.cards[4]
}
