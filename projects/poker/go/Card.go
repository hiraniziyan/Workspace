package main

import (
	"strconv"
)

type Card struct {
	rank string
	suit string
}

func NewCard(rank string, suit string) *Card {
	return &Card{
		rank: rank,
		suit: suit,
	}
}

func (c *Card) toString() string {
	return c.rank + c.suit
}

func (c *Card) rankValue() int {
	if c.rank == "A" { // A is the highest so it returns 14 rather than 1
		return 14
	}
	if c.rank == "K" {
		return 13
	}
	if c.rank == "Q" {
		return 12
	}
	if c.rank == "J" {
		return 11
	}
	if c.rank == "10" {
		return 10
	}
	value,_ := strconv.Atoi(c.rank)
	return value
}

func (c *Card) suitValue() int {
	if c.suit == "D" {
		return 1
	}
	if c.suit == "C" {
		return 2
	}
	if c.suit == "H" {
		return 3
	}
	if c.suit == "S" {
		return 4
	}
	return 0
}

func (c *Card) equals(otherCard *Card) bool {
	return c.rank == otherCard.rank && c.suit == otherCard.suit
}
