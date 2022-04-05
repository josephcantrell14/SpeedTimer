extends Node

var debug := false
var function := 0 #0-1: timer,stopwatch
var input := 0 #keyboard,touch,controller

func _ready() -> void:
    if OS.has_touchscreen_ui_hint():
        input = 1
        for node in get_tree().get_nodes_in_group("uiShiftUp"):  #mobile landscape editing
            node.rect_position.y -= 100
    else:
        input = 0
    randomize()
    set_process_input(true)
    set_process(false)
func _process(_delta:float) -> void:
    var timeLeft :float= $Timer.time_left
    var timeLeftRounded := int(floor(timeLeft))
    var timeLeftMinutesPrecalc := timeLeftRounded%3600
    var hours := int(floor(timeLeft)/3600)
    var minutes := int(timeLeftMinutesPrecalc)/60
    var seconds := int(timeLeftMinutesPrecalc%60)
    $HUD/Hours.text = str(hours)
    $HUD/Minutes.text = str(minutes)
    $HUD/Seconds.text = str(seconds)
    if $HUD.msOpacity != 0:
        $HUD/Milliseconds.text = str(timeLeft-timeLeftRounded).substr(2,3)
func _on_StartButton_pressed() -> void:
    $TimerSound.stop()
    for lineEdit in get_tree().get_nodes_in_group("time"):
        lineEdit.release_focus()
        lineEdit.deselect()
    if function == 0:
        timer()
    elif function == 1:
        stopwatch()
func timer() -> void:
    if $Timer.is_stopped():
        var waitTime :int= int($HUD/Hours.text)*3600 + int($HUD/Minutes.text)*60 + int($HUD/Seconds.text) + int($HUD/Milliseconds.text)/1000.0
        if waitTime == 0:
            return
        $Timer.wait_time = waitTime
        $Timer.start()
        set_process(true)
        $HUD/StartButton.icon = preload("res://Sprites/Icons/pause.png") #animate with a glow or something
        $HUD/ClearButton.hide()
    else:
        $Timer.stop()
        set_process(false)
        $HUD/StartButton.icon = preload("res://Sprites/Icons/play.png")
        $TimerSound.stop()
        $HUD/ClearButton.show()
func _on_Timer_timeout() -> void:
    finishTimer()
    $TimerSound.play()
    _on_ClearButton_pressed()
func finishTimer() -> void:
    set_process(false)
    $HUD/StartButton.icon = preload("res://Sprites/Icons/play.png")
func _on_TimerSound_finished() -> void:
    $HUD/StartButton.icon = preload("res://Sprites/Icons/play.png")
func stopwatch() -> void:
    if not $Stopwatch.active:
        $Stopwatch.start()
        $HUD/StartButton.icon = preload("res://Sprites/Icons/pause.png")
        $HUD/ClearButton.hide()
    else:
        finishStopwatch()
func finishStopwatch() -> void:
    $Stopwatch.end()
    $HUD/StartButton.icon = preload("res://Sprites/Icons/play.png")
    $HUD/ClearButton.show()
func _on_ClearButton_pressed() -> void:
    for lineEdit in get_tree().get_nodes_in_group("time"):
        lineEdit.text = str(0)
func _on_TimerButton_pressed() -> void:
    if function != 0:
        function = 0
        $HUD/TimerButton.modulate.a = 1
        $HUD/StopwatchButton.modulate.a = .5
        finishStopwatch()
        $HUD.setSave()
func _on_StopwatchButton_pressed() -> void:
    if function != 1:
        function = 1
        $HUD/StopwatchButton.modulate.a = 1
        $HUD/TimerButton.modulate.a = .5
        finishTimer()
        $HUD.setSave()
