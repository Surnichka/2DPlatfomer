extends Node2D

const VERTICAL_POWER_RANGE := Vector2(-300, -500)
const HORIZONTAL_POWER_RANGE := Vector2(150, 300)
const HOOK_MAX_RANGE = 150
const HOOK_MIN_RANGE = 35
onready var rayCast := $RayCast2D

func _ready():
	$Timer.connect("timeout", self, "OnHookFinished")
	
func _physics_process(delta):
	var destPos = get_local_mouse_position().normalized() * HOOK_MAX_RANGE
	rayCast.set_cast_to(destPos)
	
	if Input.is_action_just_pressed("ui_hook"):
		if rayCast.is_colliding():
			var collisionPoint = rayCast.get_collision_point()
			var distanceToPoint = collisionPoint.distance_to(get_parent().position)
			if (distanceToPoint < HOOK_MIN_RANGE):
				return
				
			var power := Vector2()
			power.x = range_lerp(abs(abs(collisionPoint.x) - abs(get_parent().position.x)), 0, HOOK_MAX_RANGE, 
									HORIZONTAL_POWER_RANGE.x, HORIZONTAL_POWER_RANGE.y)
				
			if rayCast.get_cast_to().x < 0:
				power.x *= -1
			
			var verticalDistance = (abs(get_parent().position.y) - abs(collisionPoint.y))
			power.y = range_lerp(verticalDistance, HOOK_MIN_RANGE, HOOK_MAX_RANGE,
									VERTICAL_POWER_RANGE.x, VERTICAL_POWER_RANGE.y)
			
			get_parent().is_hooking = true
			$Timer.start()
			get_parent().acceleration = power
			
func OnHookFinished():
	get_parent().is_hooking = false