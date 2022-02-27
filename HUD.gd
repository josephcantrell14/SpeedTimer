extends CanvasLayer

var themeColor := Color(1,1,1,1)
var masterVolume := 100
var resolution := 100
var uiOpacity := 100
var bgTransparency := false
var msOpacity := 100
var metronomeInterval := 0
var invertedCamera := false

func _ready() -> void:
    getSave()
func _input(event):
    if Input.is_action_just_pressed("timer"):
        get_parent()._on_StartButton_pressed()
func _on_QuitButton_pressed() -> void:
    get_tree().quit()
func getSave() -> void:
    var saveFile = File.new()
    if not saveFile.file_exists("user://speed-timer.save"):
        setSave()
    saveFile.open("user://speed-timer.save", File.READ)
    while not saveFile.eof_reached():
        var line = parse_json(saveFile.get_line())
        if line != null:
            themeColor.r = line.get("mapR",1)
            themeColor.g = line.get("mapG",1)
            themeColor.b = line.get("mapB",1)
            themeColor.a = line.get("mapA",-1)
            masterVolume = line.get("masterVolume",100)
            resolution = line.get("resolution",100)
            uiOpacity = line.get("uiOpacity",100)
            bgTransparency = line.get("bgTransparency",false)
            msOpacity = line.get("msOpacity",100)
            metronomeInterval = line.get("metronomeInterval",0)
            invertedCamera = line.get("invertedCamera",false)
            get_parent().function = line.get("function",0)
    _on_VolumeSlider_value_changed(masterVolume)
    _on_ResolutionSlider_value_changed(resolution)
    _on_UISlider_value_changed(uiOpacity)
    get_tree().get_root().set_transparent_background(bgTransparency)
    $OptionsHUD/Transparency/TransparencyCheckbox.pressed = bgTransparency
    _on_MSSlider_value_changed(msOpacity)
    _on_MetronomeSlider_value_changed(metronomeInterval)
    if get_parent().function == 0:
        get_parent()._on_TimerButton_pressed()
    else:
        get_parent()._on_StopwatchButton_pressed()
    setTheme()
    saveFile.close()
func setSave() -> void:
    var saveData = {
        "mapR" : themeColor.r,
        "mapG" : themeColor.g,
        "mapB" : themeColor.b,
        "mapA" : themeColor.a,
        "masterVolume" : masterVolume,
        "resolution" : resolution,
        "uiOpacity" : uiOpacity,
        "bgTransparency" : bgTransparency,
        "msOpacity" : msOpacity,
        "metronomeInterval" : metronomeInterval,
        "invertedCamera" : invertedCamera,
        "function" : get_parent().function
    }
    var saveFile = File.new()
    saveFile.open("user://speed-timer.save",File.WRITE)
    saveFile.store_line(to_json(saveData))
    saveFile.close()
func _on_GeneralOptionsButton_pressed() -> void:
    $OptionsHUD.show()
func _on_GeneralClose_pressed() -> void:
    $OptionsHUD.hide()
    $OptionsHUD/ThemeColorPicker.hide()
    setSave()
func _on_VolumeSlider_value_changed(value:float) -> void:
    $OptionsHUD/VolumeValue.text = str(value) + "%"
    $OptionsHUD/VolumeSlider.value = value
    if value == 0:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
    else:
        AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
        #AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -10*(100/value)+10)
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear2db(value/100))
    masterVolume = value
func _on_ResolutionSlider_value_changed(value:float) -> void:
    $OptionsHUD/ResolutionValue.text = str(value) + "%"
    $OptionsHUD/ResolutionSlider.value = value
    get_viewport().set_size(Vector2(1920*value/100,1080*value/100))
    resolution = value
func _on_UISlider_value_changed(value:float) -> void:
    uiOpacity = value
    var opacityDec := value/100
    $OptionsHUD/UIValue.text = str(value) + "%"
    $OptionsHUD/UISlider.value = value
    $TimerButton.modulate.a = opacityDec
    $StopwatchButton.modulate.a = opacityDec
    $OptionsButton.modulate.a = opacityDec
    $QuitButton.modulate.a = opacityDec
    $h.modulate.a = opacityDec
    $m.modulate.a = opacityDec
    $s.modulate.a = opacityDec
    $ms.modulate.a = opacityDec
func _on_MSSlider_value_changed(value:float) -> void:
    msOpacity = value
    $OptionsHUD/MSValue.text = str(value) + "%"
    $OptionsHUD/MSSlider.value = value
    var opacityDec := value/100
    $Milliseconds.modulate.a = opacityDec
    $Decimal.modulate.a = opacityDec
    $ms.modulate.a = opacityDec
    if value == 0:
        Engine.target_fps = 1
    else:
        Engine.target_fps = 28
func _on_FullscreenCheckbox_pressed() -> void:
    OS.window_fullscreen = not OS.window_fullscreen
func _on_ThemeButton_pressed() -> void:
    $OptionsHUD/ThemeColorPicker.visible = not $OptionsHUD/ThemeColorPicker.visible
func _on_ThemeColorPicker_color_changed(color:Color) -> void:
    themeColor = color
    setTheme()
func setTheme():
    for node in get_tree().get_nodes_in_group("theme"):
        node.modulate = themeColor
    if get_parent().function == 0:
        get_parent().get_node("HUD/StopwatchButton").modulate.a = .5
    else:
        get_parent().get_node("HUD/TimerButton").modulate.a = .5
    #$BackgroundStart.modulate = themeColor
    #get_node("OptionsHUD/GeneralClose")["custom_styles/normal"].bg_color = themeColor
func _on_MetronomeSlider_value_changed(value:float) -> void:
    metronomeInterval = value
    $OptionsHUD/MetronomeSlider.value = value
    $OptionsHUD/MetronomeValue.text = str(value) + " s"
func _on_CustomAlarmButton_pressed() -> void:
    if not $OptionsHUD/FileDialogs/AlarmFile.visible:
        $OptionsHUD/FileDialogs/AlarmFile.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
        $OptionsHUD/FileDialogs/AlarmFile.show()
        $OptionsHUD/FileDialogs/AlarmFile.popup()
func _on_AlarmFile_file_selected(path: String) -> void:
    var audio = AudioStreamPlayer.new()
    var audioLoader = AudioLoader.new()
    get_parent().get_node("TimerSound").set_stream(audioLoader.loadfile(path))
    if path.ends_with(".wav"):
        get_parent().get_node("TimerSound").stream.loop_mode = 0
func _on_CustomMetronomeButton_pressed() -> void:
    if not $OptionsHUD/FileDialogs/MetronomeFile.visible:
        $OptionsHUD/FileDialogs/MetronomeFile.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
        $OptionsHUD/FileDialogs/MetronomeFile.show()
        $OptionsHUD/FileDialogs/MetronomeFile.popup()
func _on_MetronomeFile_file_selected(path:String) -> void:
    var audio = AudioStreamPlayer.new()
    var audioLoader = AudioLoader.new()
    get_parent().get_node("Stopwatch/MetronomeSound").set_stream(audioLoader.loadfile(path))
    if path.ends_with(".wav"):
        get_parent().get_node("Stopwatch/MetronomeSound").stream.loop_mode = 0
func _on_TransparencyCheckbox_pressed() -> void:
    bgTransparency = not bgTransparency
    get_tree().get_root().set_transparent_background(bgTransparency)
    setSave()
