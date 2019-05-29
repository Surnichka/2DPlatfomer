extends Node2D

var Player = null

func _on_Area2D_body_entered(body):
	if Player.acceleration.y < 0:
		Player.acceleration.y = -200
