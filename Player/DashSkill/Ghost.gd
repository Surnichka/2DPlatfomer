extends Node

var delayTimer = 0.0
var GetCurrentAnimationInfoFn : FuncRef
var dashTotalTime = 0.0
var dashTimer = 0.0

func _ready():
	set_process(false)

func Dash(dashTime):
	Start()
	dashTotalTime = dashTime
	
func Start():
	dashTimer = 0.0
	delayTimer = 0.0
	dashTotalTime = 0.0
	set_process(true)
	
func _process(delta):
	delayTimer += delta
	dashTimer = min(dashTimer + delta, dashTotalTime)
	
	if delayTimer > 0.05:
		delayTimer -= 0.05
		
		if dashTotalTime > 0.0 and dashTimer >= dashTotalTime:
			set_process(false)
			
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
	set_process(false)

func OnTweenCompleted(tween, sprite):
	tween.queue_free()
	sprite.queue_free()