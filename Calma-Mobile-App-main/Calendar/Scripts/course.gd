# Author: Rajwol Chapagain

class_name Course
extends Resource

@export var title: String
@export var start_date: String
@export var end_date: String
@export var weekdays: Array[Time.Weekday]
@export var start_time: String
@export var end_time: String

func _init(title_: String = '', start_date_: String = '', end_date_: String = '', weekdays_: Array[Time.Weekday] = [], start_time_: String = '', end_time_: String = '') -> void:
	title = title_
	start_date = start_date_
	end_date = end_date_
	weekdays = weekdays_
	start_time = start_time_
	end_time = end_time_

func _to_string() -> String:
	return '%s %s %s %s %s %s' % [title, start_date, end_date, weekdays , start_time, end_time]

#ISO Format: YYYY-MM-DD
#Precondition: start_date is in the following format: MM/DD/YYYY
func get_start_date_string_in_iso_format() -> String:
	var split_start_date = start_date.split('/')
	return '%s-%s-%s' % [split_start_date[2], split_start_date[0], split_start_date[1]]

#Precondition: end_date is in the following format: MM/DD/YYYY
func get_end_date_string_in_iso_format() -> String:
	var split_end_date = end_date.split('/')
	return '%s-%s-%s' % [split_end_date[2], split_end_date[0], split_end_date[1]]
