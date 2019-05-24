extends Node

signal OnFinished

var dashTick = 0.0
var GetCurrentAnimationInfoFn : FuncRef
var dashTotalTime = 0.0
var dashTimer = 0.0

const dashCooldown = 1.0
var dashCooldownTimer = dashCooldown

var finished = false

func _ready():
	set_process(false)

func Dash(dashTime):
	var result = Start()
	dashTotalTime = dashTime
	return result
	
func Start():
	if dashCooldownTimer < dashCooldown:
		return false
		
	dashTimer = 0.0
	dashTick = 0.0
	dashTotalTime = 0.0
	dashCooldownTimer = 0.0
	UI.DashAbility.value = 0.0
	finished = false
	set_process(true)
	return true
	
func _process(delta : float):
	dashCooldownTimer += delta
	UI.DashAbility.value = range_lerp(dashCooldownTimer, 0, dashCooldown, 0, 100)
	
	if dashCooldownTimer == dashCooldown:
		set_process(false)
		
	if finished:
		return
		
	if dashTotalTime > 0.0 and dashTimer >= dashTotalTime:
		finished = true
		emit_signal("OnFinished")
		return
		
	dashTick += delta
	
	dashTimer = min(dashTimer + delta, dashTotalTime)
	print(dashTimer)
	
	if dashTick > 0.05:
		dashTick -= 0.05
			
		var tween = Tween.new()
		var sprite = Sprite.new()
		
		var animInfo = GetCurrentAnimationInfoFn.call_func()
		
		sprite.position = animInfo.position
		sprite.texture = animInfo.texture
		sprite.flip_h = animInfo.flip_h
		sprite.set_as_toplevel(true)
		add_child(sprite)
		add_child(tween)
		
		var tweenTime = 0.5
		if dashTotalTime > 0.0:
			tweenTime = range_lerp(dashTimer, 0.0, dashTotalTime, 1.2, 0.1)
		
		tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), tweenTime, Tween.TRANS_SINE, Tween.EASE_OUT);
		tween.connect("tween_completed", self, "OnTweenCompleted", [tween, sprite])
		tween.start()
	
func Stop():
	emit_signal("OnFinished")
	set_process(false)

func OnTweenCompleted(tween, sprite):
	tween.queue_free()
	sprite.queue_free()