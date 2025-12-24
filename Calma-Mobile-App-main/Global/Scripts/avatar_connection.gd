extends Button

#AUTHOR: Victor Smith
#CLASS: CSC 480

func _ready():
	Utils.connect("avatar_switch",change_avatar)
	change_avatar(Utils.avatars[Utils.savedItems.active_avatar])

func change_avatar(a:Texture2D):
	icon = a
