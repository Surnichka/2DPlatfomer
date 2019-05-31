extends KinematicBody2D
class_name Player

var SPEED = 22
const SPEED_AIR_X = 50
const SPEED_AIR_Y = 500
const GRAVITY = 10
const JUMP_POWER = -265
const FLOOR = Vector2(0, -1)
var isLeft = true

const SHOWDAMAGE = preload("res://Game/Misc/ShowDamage.tscn")
const DUST = preload("res://particles/dust/DustRun.tscn")
const DUST_AIR = preload("res://particles/dust/DustWalk.tscn")
const ROCKS = preload("res://particles/rocks/DirectionalRock.tscn")
const HEALTH_PARTICLE = preload("res://particles/health/healthParticles.tscn")
const SWORD = preload("res://Player/Sword.tscn")
const STATS = preload("res://Game/Stats.tscn")

var attackCounter = 0
var isAttacking = false

var is_moving = false
var on_ground = false
var is_attacking = false
var is_hooking = false
var animation_priority = 0

var is_landing = false

var jump_count = 0
var velocity = Vector2()
var acceleration = Vector2()

var _stats = STATS.instance()

func _ready():
	UI.PLAYER = self
	add_child(_stats)
	SignalSystem.connect("PlayerGotHit", self, "OnGotHit")
	SignalSystem.connect("PlayerDied", self, "OnPlayerDied")
	SignalSystem.connect("BerserkModeStart", self, "OnBerserkModeActivated")
	SignalSystem.connect("BerserkModeStop", self, "OnBerserkModeDisabled")
	
func _physics_process(delta):
	if get_node("/root/UI/HBoxContainer/DashCooldown").value < 100:
		get_node("/root/UI/HBoxContainer/DashCooldown").value += 2
		
	if get_node("/root/UI/HBoxContainer/SlashCooldown").value < 100:
		get_node("/root/UI/HBoxContainer/SlashCooldown").value += 2
		
	if get_node("/root/UI/HBoxContainer/BerserkCooldown").value < 500:
		get_node("/root/UI/HBoxContainer/BerserkCooldown").value += 2
	
	if not is_hooking:
		if Input.is_action_pressed("ui_right"):
			if is_attacking == false or is_on_floor() == false:
				acceleration.x += SPEED
				is_moving = true
				if is_attacking == false:
					$AnimatedSprite.play("Run")
					$AnimatedSprite.flip_h = false
					isLeft = true
					$Position2D.position.x *= -1
		elif Input.is_action_pressed("ui_left"):
			if is_attacking == false or is_on_floor() == false:
				acceleration.x += -SPEED
				is_moving = true
				if is_attacking == false:
					$AnimatedSprite.play("Run")
					$AnimatedSprite.flip_h = true
					isLeft = false
					$Position2D.position.x *= -1
		else:
			is_moving = false
			if on_ground == true && is_attacking == false:
				$AnimatedSprite.play("Idle")
			if is_landing:
				SignalSystem.emit_signal("CameraShake", 1, 2, 100)
				_landing_dust_particle()
				is_landing = false

	if Input.is_action_just_pressed("ui_up"):
		if jump_count == 0:
			jump_count += 1
			velocity.y = JUMP_POWER
			on_ground = false
			_jumping_dust_particle()
		
	if Input.is_action_just_pressed("ui_down") and on_ground == false:
		acceleration.y += -JUMP_POWER + 100
		$landingTimer.start()
		
	if Input.is_action_just_pressed("ui_mouse_left") && is_attacking == false:
		is_attacking = true
		get_node("/root/UI/HBoxContainer/SlashCooldown").value = 0
		var sword = SWORD.instance()
		add_child(sword)
		if $AnimatedSprite.flip_h == true:
			sword.setSwordDirection(1, $SwordPosition.position)
		else:
			sword.setSwordDirection(-1, $SwordPosition.position)
		if animation_priority == 0:
			$AnimatedSprite.play("Attack1")
			animation_priority = 1
		elif animation_priority == 1:
			$AnimatedSprite.play("Attack2")
			animation_priority = 2
		else:
			$AnimatedSprite.play("Attack3")
			animation_priority = 0

	if is_on_floor():
		if not on_ground:
			jump_count = 0
		on_ground = true
	else:
		if is_attacking == false:
			on_ground = false
			if velocity.y < 0:
				$AnimatedSprite.play("Jump")
				
	acceleration.y += GRAVITY
				
	velocity += acceleration
	
#	if is_on_floor():
#		velocity.x = clamp(velocity.x, -SPEED, SPEED)
#	else:
#		velocity.x = clamp(velocity.x, -SPEED_AIR_X, SPEED_AIR_X)
#		velocity.y = clamp(velocity.y, -SPEED_AIR_Y, SPEED_AIR_Y)
	
	velocity = move_and_slide(velocity, FLOOR)
	if not is_hooking:
		velocity.x *= 0.8
	
	acceleration = Vector2()

func _on_Timer_timeout():
	if is_moving == false or is_on_floor() == false:
		return
	create_dust_particle(0, 6)

func _landing_dust_particle():
	create_dust_particle(10, 12)
	create_dust_particle(-10, 12)
	
func create_dust_particle(_position, _amount):
	var dustParticle = DUST.instance()
	dustParticle.position = $Position2D.position
	dustParticle.position.x += _position
	dustParticle.emitting = true
	dustParticle.one_shot = true
	dustParticle.amount = _amount
	self.add_child(dustParticle)
	

func _jumping_dust_particle():
	var airDust = DUST_AIR.instance()
	airDust.position = $Position2D.position
	airDust.emitting = true
	airDust.one_shot = true
	self.add_child(airDust)
	
func _on_hit_particle():
	var bloodParticle = ROCKS.instance()
	bloodParticle.position = $SwordPosition.position
	bloodParticle.position.x -= 5
	bloodParticle.emitting = true
	bloodParticle.one_shot = true
	bloodParticle.show_behind_parent = true
	bloodParticle.SetColor(Color(255,0,0))
	self.add_child(bloodParticle)
	

func _on_AnimatedSprite_animation_finished():
	is_attacking = false

func _on_landingTimer_timeout():
	is_landing = true

func OnGotHit(damage):
	_on_hit_particle()
	
	var showDamage = SHOWDAMAGE.instance()
	add_child(showDamage)
	showDamage.Show(damage)
	showDamage.modulate = Color(255, 255, 255)
	
	_stats.DecreaseHealth(damage)

func OnPlayerDied():
	$AnimatedSprite.play("Die")
	set_collision_layer_bit(1, false)
	set_physics_process(false)
	
func OnBerserkModeActivated():
	SPEED += 20
	$AnimatedSprite.speed_scale = 2.5
	
func OnBerserkModeDisabled():
	SPEED -= 20
	$AnimatedSprite.speed_scale = 1