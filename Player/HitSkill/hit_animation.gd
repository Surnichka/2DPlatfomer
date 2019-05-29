extends Node2D

onready var Animation := $AnimatedSprite

func Show(playerPos, isLeft):
	set_scale(Vector2(0.5,0.5))
	position = playerPos
	Animation.play("hit")
	set_as_toplevel(true)
	position.y += 7

func _on_AnimatedSprite_animation_finished():
	queue_free()
