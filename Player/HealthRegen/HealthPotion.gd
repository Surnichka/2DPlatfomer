extends KinematicBody2D

var velocity : Vector2
export(float) var healAmount = 5.0
var consumerMirror = null
const HEALTH_PARTICLE = preload("res://particles/health/healthParticles.tscn")
var health = HEALTH_PARTICLE.instance()

func _ready():
	$AnimatedSprite.play("idle")
	$AnimatedSprite.set_scale(Vector2(0.02,0.02))
	$Timer.connect("timeout", self, "OnHealthFinished")

func _physics_process(delta):
	velocity.y += 10
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if is_on_floor():
		set_physics_process(false)
		
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.add_child(health)
		health.set_scale(Vector2(0.2,0.2))
		consumerMirror = body
		body._stats.regen += healAmount
		$Timer.start()
		print("ADD 5 HEALTH REGEN")
		$CollisionShape2D2.call_deferred("set_disabled", true)
		$Area2D/CollisionShape2D.call_deferred("set_disabled", true)
		hide()

func OnHealthFinished():
	print("REMOVE 5 HEALTH REGEN")
	consumerMirror._stats.regen -= healAmount
	queue_free()
	health.queue_free()