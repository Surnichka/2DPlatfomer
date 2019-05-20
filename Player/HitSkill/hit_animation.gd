extends Node2D

func Show(playerPos, isLeft):
	set_scale(Vector2(0.5,0.5))
	position = playerPos
	$AnimatedSprite.play("hit")
	set_as_toplevel(true)
	position.y += 7
	if isLeft:
		position.x += 15
	else:
		position.x -= 15


func _on_AnimatedSprite_animation_finished():
	queue_free()
