extends Node

onready var Ghost = $Ghost

const DASH_POWER = 900
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
	
func DashAbility(delta):
	if Input.is_action_just_pressed("ui_mouse_right"):
		if Ghost.Dash(0.3):
			var power = DASH_POWER
			if get_parent().get_node("AnimatedSprite").flip_h:
				power *= (-1)
	
			get_parent().velocity.x += power
			get_parent().set_collision_layer_bit(1, false)

func OnDashEnd():
	get_parent().set_collision_layer_bit(1, true)
	
func RegenAbility(delta):
	regenTimer += delta
	if regenTimer >= 0.100:
		regenTimer -= 0.100
#		get_parent().get_node("Health").AddHealth(regen / 10.0)

func OnPlayerMakeHit():
	pass
#	get_parent().get_node("Health").AddHealth(lifesteal)

func GetCurrentAnimationInfoFn():
	var Anim = get_parent().get_node("AnimatedSprite")
	var animTexture = Anim.frames.get_frame(Anim.animation, Anim.frame)
	var pos = get_parent().global_position

	return {
		position = pos,
		texture = animTexture,
		flip_h = Anim.flip_h
	}
