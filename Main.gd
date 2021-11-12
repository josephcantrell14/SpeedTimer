extends Node

var debug := false
var function := 0 #0-1: timer,stopwatch
var input := 0 #keyboard,touch,controller

func _ready() -> void:
    if OS.has_touchscreen_ui_hint():
        input = 1
    else:
        input = 0
        OS.set_window_size(Vector2(1280,720))
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
func _on_Hours_gui_input(event: InputEvent) -> void:
    if input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $HUD/Hours.select_all()
        $HUD/Minutes.deselect()
        $HUD/Seconds.deselect()
        $HUD/Milliseconds.deselect()
func _on_Minutes_gui_input(event: InputEvent) -> void:
    if input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $HUD/Minutes.select_all()
        $HUD/Hours.deselect()
        $HUD/Seconds.deselect()
        $HUD/Milliseconds.deselect()
func _on_Seconds_gui_input(event: InputEvent) -> void:
    if input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $HUD/Seconds.select_all()
        $HUD/Hours.deselect()
        $HUD/Minutes.deselect()
        $HUD/Milliseconds.deselect()
func _on_Milliseconds_gui_input(event: InputEvent) -> void:
    if input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $HUD/Milliseconds.select_all()
        $HUD/Seconds.deselect()
        $HUD/Hours.deselect()
        $HUD/Minutes.deselect()
func _on_OptionsButton_pressed() -> void:
    $HUD/OptionsHUD.show()
func _on_GeneralClose_pressed() -> void:
    $HUD/OptionsHUD.hide()
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
func _on_RotationCheckbox_toggled(button_pressed:bool) -> void:
    if button_pressed:
        OS.screen_orientation = OS.SCREEN_ORIENTATION_PORTRAIT
    else:
        OS.screen_orientation = OS.SCREEN_ORIENTATION_LANDSCAPE
func _on_CustomSoundButton_pressed() -> void:
    pass # Replace with function body.
