extends Area2D

var direction = 1
var rocks = preload("res://particles/rocks/DirectionalRock.tscn")

func setSwordDirection(dir, position):
	$Timer.start()
	direction = dir
	$CollisionShape2D.position = position
	if dir != -1:
		$CollisionShape2D.position.x *= -1

func _on_Sword_body_entered(body):
	if body.name == "Player" or body.name == "Pikachu" or body.name == "HealthPotion":
		return
	if body.name == "TileMap":
		var rock = rocks.instance()
		rock.position = $CollisionShape2D.position
		get_parent().add_child(rock)
	if body.name == "SlimeEnemy": 
		SignalSystem.emit_signal("EnemyGotHit")
		SignalSystem.emit_signal("CameraShake", 0.5, 0.4, 100)
		body.OnGotHit(35)
		var rock = rocks.instance()
		rock.SetColor(Color(0,0,255))
		rock.position = $CollisionShape2D.position
		get_parent().add_child(rock)
		body.Health.TakeDamage(35)
		
func _on_Timer_timeout():
	queue_free()
