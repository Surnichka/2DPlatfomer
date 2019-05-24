extends "res://Enemy/Enemy.gd"

var level = 0 setget SetLevel

func SetLevel(lvl):
	$Label.text = "Level " + str(lvl)