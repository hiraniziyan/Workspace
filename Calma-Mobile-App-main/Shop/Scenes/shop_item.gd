extends Button
class_name ShopItem

#AUTHOR: Victor Smith
#CLASS: CSC 480

enum item_types{THEME,AVATAR}

@export var toolTipIcon: TextureRect
@export var toolDescNode: RichTextLabel

@export var cost:int = 1
@export var linked_item_index:int = 0
@export var item_type:item_types = item_types.THEME
@export var shop_icon: Texture2D:
	set(value):
		icon = value
		if is_instance_valid(toolTipIcon):
			toolTipIcon.texture = value
		shop_icon = value
@export var bought: bool = false
@export var item_name: String = "Unnamed"
@export var equiped: bool = false

@export var desc: String = "No Description":
	set(value):
		if is_instance_valid(toolDescNode):
			toolDescNode.text = value
		desc = value


func _ready():
	toolTipIcon.texture = shop_icon
	icon = shop_icon
	toolDescNode.text = desc
	if item_type == item_types.THEME:
		bought = Utils.savedItems.bought_guis[linked_item_index]
	elif item_type == item_types.AVATAR:
		bought = Utils.savedItems.bought_avatars[linked_item_index]
	
	if bought:
		$CanvasLayer/CenterContainer/ToolTip/VSplitContainer/BuyEqButton.icon = load("res://Shop/Assets/Placeholders/Equip Button PH.png")
	Utils.connect("theme_switch",change_theme)
	change_theme(Utils.gui_themes[Utils.savedItems.active_gui])
#Pressing button only brings up tool tip

func change_theme(t:Theme):
	theme = t

#Make a script to add to any gui element that I can just attatch when needed
#The script will just connect a method to change the theme of the element to a signal
#from either Utils or shop (Probably Utils)

func hide_tool():
	$CanvasLayer.visible = false

func _on_button_down():
	get_tree().call_group("ShopItems","hide_tool")
	$CanvasLayer.visible = true

func _on_close_button_button_down():
	$CanvasLayer.visible = false

func _on_buy_eq_button_button_down() -> void:
	if !bought:
		if Utils.savedItems.coins >= cost:
			bought = true
			if item_type == item_types.THEME:
				Utils.savedItems.bought_guis[linked_item_index] = 1
			elif item_type == item_types.AVATAR:
				Utils.savedItems.bought_avatars[linked_item_index] = 1
			Utils.save_utils()
			Utils.deduct_coins(cost)
			$CanvasLayer/CenterContainer/ToolTip/VSplitContainer/BuyEqButton.icon = load("res://Shop/Assets/Placeholders/Equip Button PH.png")
	else:
		if item_type == item_types.THEME:
			Utils.change_theme(linked_item_index)
		elif item_type == item_types.AVATAR:
			Utils.change_avatar(linked_item_index)
			
