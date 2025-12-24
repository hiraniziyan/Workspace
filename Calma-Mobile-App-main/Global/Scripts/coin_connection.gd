# Author: Rajwol Chapagain

extends Label

func _ready():
	Utils.connect("coins_changed", update_coins)
	update_coins(Utils.savedItems.coins)

func update_coins(coins: int):
	text = str(coins)
