extends Node

onready var Ghost = $Ghost

var berserk_mode_duration := 5.0
var berserk_mode_on = false

const DASH_POWER = 900
var health : float = 100.0
var max_health := 100.0
var regen : float = 0.0
var lifesteal : float = 0.0

var regenTimer := 0.0

func _ready():
	Ghost.GetCurrentAnimationInfoFn = funcref(self, "GetCurrentAnimationInfoFn")
	Ghost.connect("OnFinished", self, "OnDashEnd")
	SignalSystem.connect("EnemyGotHit", self, "OnPlayerMakeHit")

func _process(delta):
	RegenAbility(delta)
	DashAbility(delta)
	BerserkAbility()
	
func DashAbility(delta):
	if berserk_mode_on:
		return
		
	if Input.is_action_just_pressed("ui_mouse_right"):
		if Ghost.Dash(0.3):
			var power = DASH_POWER
			if get_parent().get_node("AnimatedSprite").flip_h:
				power *= (-1)
	
			get_parent().velocity.x += power
			get_parent().set_collision_layer_bit(1, false)

func OnDashEnd():
	if berserk_mode_on:
		SignalSystem.emit_signal("BerserkModeStop")
		berserk_mode_on = false
	get_parent().set_collision_layer_bit(1, true)
	
func RegenAbility(delta):
	regenTimer += delta
	if regenTimer >= 0.100:
		regenTimer -= 0.100
		health = min(health + (regen / 5.0), max_health)

func DecreaseHealth(hp):
	if (health - hp) <= 0:
		health = 0
		SignalSystem.emit_signal("PlayerDied")
	else:
		health -= hp
		
func BerserkAbility():
	if berserk_mode_on:
		DecreaseHealth(0.1)
		return
		
	if Input.is_action_just_pressed("ui_berserk_mode"):
		berserk_mode_on = true
		Ghost.Dash(berserk_mode_duration)
		SignalSystem.emit_signal("BerserkModeStart")
	
func GetCurrentAnimationInfoFn():
	var Anim = get_parent().get_node("AnimatedSprite")
	var animTexture = Anim.frames.get_frame(Anim.animation, Anim.frame)
	var pos = get_parent().global_position

	return {
		position = pos,
		texture = animTexture,
		flip_h = Anim.flip_h
	}
