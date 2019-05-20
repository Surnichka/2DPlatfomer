extends Node

onready var DashEndTimer = $DashEndTimer
onready var Ghost = $Ghost

const DASH_POWER = 450
var regen : float = 0.0
var lifesteal : float = 0.0

var regenTimer := 0.0
var dashDelayTimer = 0.0

func _ready():
	Ghost.GetCurrentAnimationInfoFn = funcref(self, "GetCurrentAnimationInfoFn")
	DashEndTimer.connect("timeout", self, "OnDashEnd")
	SignalSystem.connect("EnemyGotHit", self, "OnPlayerMakeHit")

func _process(delta):
	RegenAbility(delta)
	DashAbility(delta)
	
func DashAbility(delta):
	if dashDelayTimer < 0.5:
		dashDelayTimer += delta	
		return
		
	if Input.is_action_just_pressed("ui_mouse_right"):
		Ghost.Dash(0.3)
		
		var power = DASH_POWER
		if get_parent().get_node("AnimatedSprite").flip_h:
			power *= (-1)

		get_parent().velocity.x += power
		get_parent().set_collision_layer_bit(1, false)
		get_node("/root/UI/DashCooldown").value = 0
		DashEndTimer.start()
		dashDelayTimer = 0.0

func OnDashEnd():
	get_parent().set_collision_layer_bit(1, true)
	
func RegenAbility(delta):
	regenTimer += delta
	if regenTimer >= 0.100:
		regenTimer -= 0.100
		get_parent().get_node("Health").AddHealth(regen / 10.0)

func OnPlayerMakeHit():
	get_parent().get_node("Health").AddHealth(lifesteal)

func GetCurrentAnimationInfoFn():
	var Anim = get_parent().get_node("AnimatedSprite")
	var animTexture = Anim.frames.get_frame(Anim.animation, Anim.frame)
	var pos = get_parent().global_position

	return {
		position = pos,
		texture = animTexture,
		flip_h = Anim.flip_h
	}
