extends CanvasLayer

onready var DashAbility = $HBoxContainer/DashCooldown
onready var SlashAbility = $HBoxContainer/SlashCooldown

onready var Highscore = $Highscore
onready var MonsterKilled = $MonsterKilled

onready var HealthBar = $HealthBar
onready var Heart = $Heart
	
func _ready():
	Heart.set_frame(3)
	
func TakeDamage(damage):
	HealthBar.value -= damage
	if HealthBar.value <= 0:
		HealthBar.value = 0
		emit_signal("died")
		
func SetHealth(health:float):
	$HealthBar.max_value = health
	$HealthBar.value = health
	
func AddHealth(health):
	HealthBar.value += health

func _on_Heart_animation_finished():
	Heart.stop()
	
