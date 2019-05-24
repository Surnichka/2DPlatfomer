extends "res://Enemy/Enemy.gd"

func SetLevel(lvl):
	level = lvl
	$Label.text = "Level " + str(lvl)