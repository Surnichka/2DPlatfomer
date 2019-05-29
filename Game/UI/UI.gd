extends CanvasLayer

onready var DashAbility = $HBoxContainer/DashCooldown
onready var SlashAbility = $HBoxContainer/SlashCooldown

onready var Highscore = $Highscore
onready var MonsterKilled = $MonsterKilled

onready var HealthBar = $HealthBar
onready var Heart = $Heart

var PLAYER = null setget Init

func _ready():
	SignalSystem.connect("PlayerGotHit", self, "StartTakeDamageAnim")
	Heart.set_frame(3)
	
func StartTakeDamageAnim(damage):
	Heart.set_frame(0)
	Heart.play("hit")

func _on_Heart_animation_finished():
	Heart.stop()
	
func _process(delta):
	HealthBar.value = PLAYER._stats.health

func Init(player):
	if player == null:
		return
		
	PLAYER = player
	HealthBar.max_value = PLAYER._stats.max_health
	HealthBar.value = PLAYER._stats.health
	
	
	