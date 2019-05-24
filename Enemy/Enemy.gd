extends KinematicBody2D

const SHOWDAMAGE = preload("res://Game/Misc/ShowDamage.tscn")
onready var Animation := $AnimatedSprite
onready var Health := $HealthBar
const HEALTH_POTION = preload("res://Player/HealthRegen/HealthPotion.tscn")

var GRAVITY = 10
const FLOOR = Vector2(0, -1)

var level = 1

var speed = 30
var direction = 1
var velocity = Vector2()
var attacking = false

var elapsedTimer : float = 0

var _health :float setget SetHealth
var damage :int setget SetDamage
var healthRegen :float setget SetRegen

func _ready():
	$AnimatedSprite.connect("animation_finished", self, "OnAnimationFinished")
	Health.SetHealth(_health)
	
func _physics_process(delta):
	elapsedTimer += delta
	if elapsedTimer >= 0.100:
		elapsedTimer -= 0.100
		Health.AddHealth(healthRegen / 10)
		
	var moveSpeed = speed
	
	if $SightView.is_colliding():
		moveSpeed *= 2

	if $AttackRange.is_colliding():
		attacking = true
		$AnimatedSprite.play("attack")
	else:
		attacking = false
		$AnimatedSprite.play("move")
		
	velocity.x = moveSpeed * direction
	
	if direction == 1:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	
	if not attacking:
		if ($RayCast2D.is_colliding() == false) or is_on_wall():
			direction = direction * -1
			$RayCast2D.position.x *= -1
			$SightView.rotation_degrees *= -1
			$AttackRange.rotation_degrees *= -1

func _on_HealthBar_died():
	$AnimatedSprite.play("die")
	Health.hide()
	set_physics_process(false)

func OnAnimationFinished():
	if $AnimatedSprite.animation == "attack":
		SignalSystem.emit_signal("PlayerGotHit", damage)
			
	if $AnimatedSprite.animation == "die":
		SignalSystem.emit_signal("EnemyDied", self)
		var healthPotion = HEALTH_POTION.instance()
		get_tree().get_root().get_node("World").add_child(healthPotion)
		healthPotion.position = global_position
#		healthPotion.set_as_toplevel(true)
		healthPotion.velocity.x = (randi() % 20 + 10)
		if randi() % 2 == 0:
			healthPotion.velocity.x *= (-1)
		healthPotion.velocity.y = -(randi() % 200 + 100)
		if int(UI.Highscore.text) < level:
			UI.Highscore.text = str(level)
		UI.MonsterKilled.text = str(int(UI.MonsterKilled.text) + 1)
		queue_free()

func OnGotHit(damage):
	var showDamage = SHOWDAMAGE.instance()
	add_child(showDamage)
	showDamage.Show(damage)
	showDamage.modulate = Color(255,255,255)

func SetHealth(h):
	_health = h
	if null != Health:
		Health.SetHealth(_health)

func SetDamage(d):
	damage = d
	
func SetRegen(regen):
	healthRegen = regen
	