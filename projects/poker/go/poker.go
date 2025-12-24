package main

import (
	"fmt"
	"math/rand"
	"os"
	"strings"
)

func main() {
	fmt.Println("\n*** P O K E R  H A N D  A N A L Y Z E R ***\n\n")

	var hand []*Card

	args := os.Args[1:]

	if len(args) == 0 {
		fmt.Println("*** USING RANDOMIZED DECK OF CARDS ***")
		hand = generateDeck()
	}

	if len(args) == 1 {
		filename := args[0]
		fmt.Println("*** USING TEST DECK ***\n")
		fmt.Println("*** File:", filename)
		hand = processFile(filename)
	}

	if len(args) == 0 {
		fmt.Println("*** Here is the hand")
		printHand(hand)
	}

	hands := generateCombinations(hand)
	printWin(hands)
}

func generateDeck() []*Card {
	suits := [4]string{"D", "C", "H", "S"}
	ranks := [13]string{"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
	allCards := []*Card{}

	for _, s := range suits {
		for _, r := range ranks {
			allCards = append(allCards, NewCard(r, s))
		}
	}

	var deck [52]*Card

	for _, c := range allCards {
		pos := rand.Intn(52)
		for deck[pos] != nil {
			pos = (pos + 1) % 52
		}
		deck[pos] = c
	}

	fmt.Println("\n*** Shuffled 52 card deck:")
	for i, card := range deck {
		fmt.Print(card.toString(), " ")
		if (i+1)%13 == 0 {
			fmt.Println()
		}
	}
	fmt.Println()

	sixCardHand := []*Card{}
	for i := 0; i < 6; i++ {
		sixCardHand = append(sixCardHand, deck[i])
	}
	return sixCardHand
}

func printHand(hand []*Card) {
	fmt.Print(" ")
	for _, c := range hand {
		fmt.Print(c.toString(), " ")
	}
	fmt.Println("\n")
}

func generateCombinations(hand []*Card) []*Hand {
	hands := []*Hand{}
	cardIndexTracker := 0
	excludedIndex := 0

	for i := 0; i < len(hand); i++ {
		newHand := []*Card{}

		for j := 0; j < len(hand)-1; j++ {
			index := cardIndexTracker % len(hand)
			cardIndexTracker++
			newHand = append(newHand, hand[index])
			excludedIndex = (index + 1) % len(hand)
		}

		hands = append(hands, NewHand(newHand, hand[excludedIndex]))
	}

	fmt.Println("*** Hand Combinations...")
	for _, h := range hands {
		h.printHand()
	}
	fmt.Println()

	return hands
}

func printWin(hands []*Hand) {
	sortHands(hands)
	fmt.Println(" --- HIGH HAND ORDER ---")
	for _, h := range hands {
		h.printWithLabel()
	}
	fmt.Println()
}

func processFile(filename string) []*Card {
	content, _ := os.ReadFile(filename)

	line := strings.TrimSpace(string(content))
	tokens := strings.Split(line, ",")
	hand := []*Card{}
	duplicate := false
	var duplicateCard *Card

	for _, token := range tokens {
		cardStr := strings.TrimSpace(token)
		var rank string
		var suit string

		if len(cardStr) == 3 {
			rank = cardStr[:2]
			suit = cardStr[2:]
		} else {
			rank = cardStr[:1]
			suit = cardStr[1:]
		}

		newCard := NewCard(rank, suit)

		for _, c := range hand {
			if newCard.equals(c) {
				duplicate = true
				duplicateCard = c
			}
		}
		hand = append(hand, newCard)
	}

	if strings.HasPrefix(line, "10") {
		fmt.Println(line + "\n")
	} else {
		fmt.Println(" " + line + "\n")
	}

	if duplicate {
		fmt.Println("*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n")
		fmt.Println("*** DUPLICATE:", duplicateCard.toString(), "***")
		os.Exit(1)
	}

	return hand
}

func highCardTieBreaker(h1, h2 *Hand) bool {
	for i := len(h1.cards) - 1; i >= 0; i-- {
		if h1.cards[i].rankValue() > h2.cards[i].rankValue() {
			return false
		} else if h1.cards[i].rankValue() < h2.cards[i].rankValue() {
			return true
		} else {
			if h1.cards[i].suitValue() > h2.cards[i].suitValue() {
				return false
			} else if h1.cards[i].suitValue() < h2.cards[i].suitValue() {
				return true
			}
		}
	}
	return false
}

func pairTieBreaker(h1, h2 *Hand) bool {
	var pair1 []*Card
	var pair2 []*Card
	var other1 []*Card
	var other2 []*Card

	for _, c := range h1.cards {
		if c.rankValue() == h1.highestCard.rankValue() {
			pair1 = append(pair1, c)
		} else {
			other1 = append(other1, c)
		}
	}
	for _, c := range h2.cards {
		if c.rankValue() == h2.highestCard.rankValue() {
			pair2 = append(pair2, c)
		} else {
			other2 = append(other2, c)
		}
	}

	for i := len(pair1) - 1; i >= 0; i-- {
		if pair1[i].rankValue() > pair2[i].rankValue() {
			return false
		} else if pair1[i].rankValue() < pair2[i].rankValue() {
			return true
		} else {
			if pair1[i].suitValue() > pair2[i].suitValue() {
				return false
			} else if pair1[i].suitValue() < pair2[i].suitValue() {
				return true
			}
		}
	}

	for i := len(other1) - 1; i >= 0; i-- {
		if other1[i].rankValue() > other2[i].rankValue() {
			return false
		} else if other1[i].rankValue() < other2[i].rankValue() {
			return true
		} else {
			if other1[i].suitValue() > other2[i].suitValue() {
				return false
			} else if other1[i].suitValue() < other2[i].suitValue() {
				return true
			}
		}
	}
	return false
}

func threeTieBreaker(h1, h2 *Hand) bool {
	var trip1 []*Card
	var trip2 []*Card
	var other1 []*Card
	var other2 []*Card

	for _, c := range h1.cards {
		if c.rankValue() == h1.highestCard.rankValue() {
			trip1 = append(trip1, c)
		} else {
			other1 = append(other1, c)
		}
	}
	for _, c := range h2.cards {
		if c.rankValue() == h2.highestCard.rankValue() {
			trip2 = append(trip2, c)
		} else {
			other2 = append(other2, c)
		}
	}

	for i := len(trip1) - 1; i >= 0; i-- {
		if trip1[i].rankValue() > trip2[i].rankValue() {
			return false
		} else if trip1[i].rankValue() < trip2[i].rankValue() {
			return true
		} else {
			if trip1[i].suitValue() > trip2[i].suitValue() {
				return false
			} else if trip1[i].suitValue() < trip2[i].suitValue() {
				return true
			}
		}
	}

	for i := len(other1) - 1; i >= 0; i-- {
		if other1[i].rankValue() > other2[i].rankValue() {
			return false
		} else if other1[i].rankValue() < other2[i].rankValue() {
			return true
		} else {
			if other1[i].suitValue() > other2[i].suitValue() {
				return false
			} else if other1[i].suitValue() < other2[i].suitValue() {
				return true
			}
		}
	}
	return false
}

func fourTieBreaker(h1, h2 *Hand) bool {
	if h1.highestCard.rankValue() > h2.highestCard.rankValue() {
		return false
	} else if h1.highestCard.rankValue() < h2.highestCard.rankValue() {
		return true
	} else {
		return h1.highestCard.suitValue() < h2.highestCard.suitValue()
	}
}

func twoPairTieBreaker(h1, h2 *Hand) bool {
	var pairs1 []*Card
	var pairs2 []*Card

	pairs1 = append(pairs1, h1.highestCard)
	pairs2 = append(pairs2, h2.highestCard)

	for i := 0; i < len(h1.cards); i++ {
		if !h1.cards[i].equals(h1.highestCard) {
			pairs1 = append(pairs1, h1.cards[i])
		}
		if !h2.cards[i].equals(h2.highestCard) {
			pairs2 = append(pairs2, h2.cards[i])
		}
	}

	for i := len(pairs1) - 1; i >= 0; i-- {
		if pairs1[i].rankValue() > pairs2[i].rankValue() {
			return false
		} else if pairs1[i].rankValue() < pairs2[i].rankValue() {
			return true
		} else if pairs1[i].suitValue() > pairs2[i].suitValue() {
			return false
		} else if pairs1[i].suitValue() < pairs2[i].suitValue() {
			return true
		}
	}
	return false
}

func straightTieBreaker(h1, h2 *Hand) bool {
	return highCardTieBreaker(h1, h2)
}
func straightFlushTieBreaker(h1, h2 *Hand) bool{
	return highCardTieBreaker(h1, h2)
}
func flushTieBreaker(h1, h2 *Hand) bool {
	return highCardTieBreaker(h1, h2)
}
func fullHouseTieBreaker(h1, h2 *Hand) bool {
	return threeTieBreaker(h1, h2)
}

func sortHands(hands []*Hand) {
	swapped := true
	for swapped {
		swapped = false
		for i := 0; i < len(hands)-1; i++ {
			h1 := hands[i]
			h2 := hands[i+1]

			if h1.handValue < h2.handValue {
				hands[i], hands[i+1] = hands[i+1], hands[i]
				swapped = true
			} else if h1.handValue == h2.handValue {
				needSwap := false

				if h1.label == "High Card" && h2.label == "High Card" {
					needSwap = highCardTieBreaker(h1, h2)
				} else if h1.label == "Pair" && h2.label == "Pair" {
					needSwap = pairTieBreaker(h1, h2)
				} else if h1.label == "Four of a Kind" && h2.label == "Four of a Kind" {
					needSwap = fourTieBreaker(h1, h2)
				} else if h1.label == "Three of a Kind" && h2.label == "Three of a Kind" {
					needSwap = threeTieBreaker(h1, h2)
				} else if h1.label == "Full House" && h2.label == "Full House" {
					needSwap = fullHouseTieBreaker(h1, h2)
				} else if h1.label == "Straight Flush" && h2.label == "Straight Flush" {
					needSwap = straightFlushTieBreaker(h1, h2)
				} else if h1.label == "Flush" && h2.label == "Flush" {
					needSwap = flushTieBreaker(h1, h2)
				} else if h1.label == "Straight" && h2.label == "Straight" {
					needSwap = straightTieBreaker(h1, h2)
				} else if h1.label == "Two Pair" && h2.label == "Two Pair" {
					needSwap = twoPairTieBreaker(h1, h2)
				}

				if needSwap {
					hands[i], hands[i+1] = hands[i+1], hands[i]
					swapped = true
				}
			}
		}
	}
}

