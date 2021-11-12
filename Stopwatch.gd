extends Node

var active := false
var time := 0.0
var metronomeTime := 0.0
onready var hud := get_parent().get_node("HUD")
onready var hours := hud.get_node("Hours")
onready var minutes := hud.get_node("Minutes")
onready var seconds := hud.get_node("Seconds")
onready var ms := hud.get_node("Milliseconds")

func _ready() -> void:
    set_process(false)
func start() -> void:
    time = float(ms.text)/1000 + int(seconds.text) + int(minutes.text)*60 + int(hours.text)*3600
    set_process(true)
    active = true
func _process(delta:float) -> void: #process for stopwatch
    time += delta
    var timeInt = int(time)
    var timeIntPrecalc = timeInt%3600
    hours.text = str(timeInt/3600)
    minutes.text = str(timeIntPrecalc/60)
    seconds.text = str(timeIntPrecalc%60)
    if hud.msOpacity != 0:
        ms.text = str(time - int(floor(time))).substr(2,3)
    if hud.metronomeInterval != 0:
        metronomeTime += delta
        if metronomeTime >= hud.metronomeInterval:
            $MetronomeSound.play()
            metronomeTime = 0.0
func end() -> void:
    set_process(false)
    active = false
    metronomeTime = 0.0
