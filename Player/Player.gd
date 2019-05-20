extends KinematicBody2D


const SPEED = 22
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
const RAIN = preload("res://particles/rain/rain_particle.tscn")
const RAIN_SPLASH = preload("res://World/enviroment/rain/RainSplash.tscn")
const HIT_SKILL = preload("res://Player/HitSkill/hit_animation.tscn")
var rain = RAIN.instance() #386 camera size
var rain_splash = RAIN_SPLASH.instance()


var attackCounter = 0
var isAttacking = false

var is_moving = false
var on_ground = false
var is_attacking = false

var animation_priority = 0

var is_landing = false

var jump_count = 0
var velocity = Vector2()
var acceleration = Vector2()

var _stats = STATS.instance()

func _ready():
	add_child(_stats)
#	$Camera2D.add_child(rain)
#	rain.position.y = -120
#	rain.set_scale(Vector2(0.5,0.5))
#	$Camera2D.add_child(rain_splash)
#	rain_splash.position.y = 36
#	rain_splash.set_scale(Vector2(0.2,0.2))
	
	SignalSystem.connect("PlayerGotHit", self, "OnGotHit")
	
func _physics_process(delta):
	if get_node("/root/UI/DashCooldown").value < 100:
		get_node("/root/UI/DashCooldown").value += 2
		
	if get_node("/root/UI/SlashCooldown").value < 100:
		get_node("/root/UI/SlashCooldown").value += 2
	
	if Input.is_action_pressed("ui_right"):
		if is_attacking == false or is_on_floor() == false:
			acceleration.x = SPEED
			is_moving = true
			if is_attacking == false:
				$AnimatedSprite.play("Run")
				$AnimatedSprite.flip_h = false
				isLeft = true
				$Position2D.position.x *= -1
	elif Input.is_action_pressed("ui_left"):
		if is_attacking == false or is_on_floor() == false:
			acceleration.x = -SPEED
			is_moving = true
			if is_attacking == false:
				$AnimatedSprite.play("Run")
				$AnimatedSprite.flip_h = true
				isLeft = false
				$Position2D.position.x *= -1
	else:
		acceleration.x = 0
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
		#elif jump_count == 1:
		#	jump_count += 1
		#	acceleration.y += JUMP_POWER / 2
			
		
	if Input.is_action_just_pressed("ui_down") and on_ground == false:
		acceleration.y = -JUMP_POWER + 100
		$landingTimer.start()
		
	if Input.is_action_just_pressed("ui_mouse_left") && is_attacking == false:
		if is_on_floor():
			velocity.x = 0
		is_attacking = true
		get_node("/root/UI/SlashCooldown").value = 0
		var hit = HIT_SKILL.instance()
		add_child(hit)
		hit.Show(global_position, isLeft)
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
	velocity = move_and_slide(velocity, FLOOR)
	velocity.x *= 0.8
	clamp(velocity.x, 0, SPEED)
	clamp(velocity.y, 0, SPEED*10)
	
	acceleration = Vector2()

func _on_Timer_timeout():
	_walking_dust_particle()

func _walking_dust_particle():
	if is_moving == false or is_on_floor() == false:
		return
	var walkDust = DUST.instance()
	walkDust.position = $Position2D.position
	walkDust.emitting = true
	walkDust.one_shot = true
	self.add_child(walkDust)
	
func _landing_dust_particle():
	var leftDust = DUST.instance()
	leftDust.position = $Position2D.position
	leftDust.position.x -= 10
	leftDust.emitting = true
	leftDust.one_shot = true
	leftDust.amount = 12
	self.add_child(leftDust)
	
	var rightDust = DUST.instance()
	rightDust.position = $Position2D.position
	rightDust.position.x += 10
	rightDust.emitting = true
	rightDust.amount = 12
	rightDust.one_shot = true
	self.add_child(rightDust)

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
	$Health.TakeDamage(damage)
	var showDamage = SHOWDAMAGE.instance()
	add_child(showDamage)
	showDamage.Show(damage)
	showDamage.modulate = Color(255, 255, 0)
	