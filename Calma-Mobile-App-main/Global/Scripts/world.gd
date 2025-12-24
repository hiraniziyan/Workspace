# Author: Rajwol Chapagain

extends Node2D

func _ready() -> void:
	%PanelController.switch_to_scene(1)
	
func _on_settings_panel_schedule_imported() -> void:
	%PanelController.switch_to_scene(1)
