extends KinematicBody2D

const SPEED = 100
const GRAVITY = 10
const JUMP_POWER = -265
const FLOOR = Vector2(0, -1)

var isAttacking = false

var is_moving = false
var on_ground = false
var is_attacking = false

var is_landing = false

var jump_count = 0
var velocity = Vector2()
var acceleration = Vector2()

func _ready():
	$AnimatedSprite.play("Idle")

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		if is_attacking == false or is_on_floor() == false:
			acceleration.x = SPEED
			is_moving = true
			if is_attacking == false:
				$AnimatedSprite.play("Run")
				$AnimatedSprite.flip_h = false
				if sign($Position2D.position.x) == -1:
					$Position2D.position.x *= -1
	elif Input.is_action_pressed("ui_left"):
		if is_attacking == false or is_on_floor() == false:
			acceleration.x = -SPEED
			is_moving = true
			if is_attacking == false:
				$AnimatedSprite.play("Run")
				$AnimatedSprite.flip_h = true
				if sign($Position2D.position.x) == 1:
					$Position2D.position.x *= -1
	else:
		acceleration.x = 0
		is_moving = false
		if on_ground == true && is_attacking == false:
			$AnimatedSprite.play("Idle")
		if is_landing:
			SignalSystem.emit_signal("CameraShake", 1, 2, 100)
			is_landing = false
			
		if Input.is_action_just_pressed("ui_up"):
			if jump_count == 0:
				jump_count += 1
				velocity.y = JUMP_POWER
				on_ground = false
				
	if Input.is_action_just_pressed("ui_mouse_left") && is_attacking == false:
		if is_on_floor():
			velocity.x = 0
		is_attacking = true
		$AnimatedSprite.play("Attack1")
		
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
	
func _on_AnimatedSprite_animation_finished():
	is_attacking = false