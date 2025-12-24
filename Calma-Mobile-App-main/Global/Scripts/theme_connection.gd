extends Control

#AUTHOR: Victor Smith
#CLASS: CSC 480

func _ready():
	Utils.connect("theme_switch",change_theme)
	change_theme(Utils.gui_themes[Utils.savedItems.active_gui])

func change_theme(t:Theme):
	theme = t
