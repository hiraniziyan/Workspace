extends Node

#AUTHOR: Victor Smith
#CLASS: CSC 480

var gui_themes: Array = [load("res://Shop/Assets/Themes/DefaultTheme.tres"),
					load("res://Shop/Assets/Themes/PlaceHolderTestTheme.tres")]

var avatars: Array = [load("res://Shop/ProfileSprites/Bear.png"),
					load("res://Shop/ProfileSprites/BullDog.png"),
					load("res://Shop/ProfileSprites/OWL.png"),
					load("res://Shop/ProfileSprites/YellowJacket.png")]

const SAVE_PATH:String = "user://Utils.tres"

var savedItems:SavedItems = SavedItems.new()
signal theme_switch(theme:Theme)
signal avatar_switch(avatar:Texture2D)
signal coins_changed(amount: int)

func _ready():
	if FileAccess.file_exists(SAVE_PATH):
		savedItems = ResourceLoader.load(SAVE_PATH)
	
	change_theme(savedItems.active_gui)
	change_avatar(savedItems.active_avatar)
	

func change_theme(theme: int):
	if theme < gui_themes.size():
		savedItems.active_gui = theme
		save_utils()
		theme_switch.emit(gui_themes[savedItems.active_gui])

func change_avatar(avatar: int):
	if avatar < avatars.size():
		savedItems.active_avatar = avatar
		save_utils()
		avatar_switch.emit(avatars[savedItems.active_avatar])

func save_utils():
	ResourceSaver.save(savedItems,SAVE_PATH)

func add_coins(num: int):
	savedItems.coins += num
	save_utils()
	coins_changed.emit(savedItems.coins)

func deduct_coins(num: int):
	savedItems.coins -= num
	save_utils()
	coins_changed.emit(savedItems.coins)
