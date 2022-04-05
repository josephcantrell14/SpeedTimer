extends CanvasLayer

var themeColor := Color(1,1,1,1)
var masterVolume := 100
var windowResolution := Vector2(1280,720)
var renderResolution := 100
var uiOpacity := 100
var bgTransparency := false
var alwaysOnTop := false
var msOpacity := 100
var metronomeInterval := 0
var invertedCamera := false

func _ready() -> void:
    getSave()
    $Hours.append_at_cursor("0")
    $Minutes.append_at_cursor("0")
    $Seconds.append_at_cursor("0")
    $Milliseconds.append_at_cursor("0")
func _input(event):
    if Input.is_action_just_pressed("timer"):
        get_parent()._on_StartButton_pressed()
    elif Input.is_action_just_pressed("162p"):
        setWindowResolution(Vector2(288,162))
    elif Input.is_action_just_pressed("270p"):
        setWindowResolution(Vector2(480,270))
    elif Input.is_action_just_pressed("450p"):
        setWindowResolution(Vector2(800,450))
    elif Input.is_action_just_pressed("720p"):
        setWindowResolution(Vector2(1280,720))
    elif Input.is_action_just_pressed("1080p"):
        setWindowResolution(Vector2(1920,1080))
    elif Input.is_action_just_pressed("1440p"):
        setWindowResolution(Vector2(2560,1440))
    elif Input.is_action_just_pressed("2160p"):
        setWindowResolution(Vector2(3840,2160))
func setWindowResolution(resolution) -> void:
    windowResolution = resolution
    OS.set_window_size(windowResolution)
    setSave()
func _on_QuitButton_pressed() -> void:
    windowResolution = OS.window_size
    setSave()
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
            windowResolution[0] = line.get("windowResolutionX",1920)
            windowResolution[1] = line.get("windowResolutionY",1080)
            renderResolution = line.get("renderResolution",100)
            uiOpacity = line.get("uiOpacity",100)
            bgTransparency = line.get("bgTransparency",false)
            alwaysOnTop = line.get("alwaysOnTop",false)
            msOpacity = line.get("msOpacity",100)
            metronomeInterval = line.get("metronomeInterval",0)
            invertedCamera = line.get("invertedCamera",false)
            get_parent().function = line.get("function",0)
    _on_VolumeSlider_value_changed(masterVolume)
    setWindowResolution(windowResolution)
    _on_ResolutionSlider_value_changed(renderResolution)
    _on_UISlider_value_changed(uiOpacity)
    OS.window_per_pixel_transparency_enabled = bgTransparency
    get_tree().get_root().set_transparent_background(bgTransparency)
    $OptionsHUD/Transparency/TransparencyCheckbox.pressed = bgTransparency
    OS.set_window_always_on_top(alwaysOnTop)
    $OptionsHUD/AlwaysOnTop/AlwaysOnTopCheckbox.pressed = alwaysOnTop
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
        "windowResolutionX" : windowResolution[0],
        "windowResolutionY" : windowResolution[1],
        "renderResolution" : renderResolution,
        "uiOpacity" : uiOpacity,
        "bgTransparency" : bgTransparency,
        "alwaysOnTop" : alwaysOnTop,
        "msOpacity" : msOpacity,
        "metronomeInterval" : metronomeInterval,
        "invertedCamera" : invertedCamera,
        "function" : get_parent().function
    }
    var saveFile = File.new()
    saveFile.open("user://speed-timer.save",File.WRITE)
    saveFile.store_line(to_json(saveData))
    saveFile.close()
func _on_OptionsButton_pressed() -> void:
    $OptionsHUD.show()
func _on_OptionsClose_pressed() -> void:
    $OptionsHUD.hide()
    $OptionsHUD/ThemeColorPicker.hide()
    windowResolution = OS.window_size
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
    renderResolution = value
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
func _on_FullscreenCheckbox_pressed() -> void:
    OS.window_fullscreen = not OS.window_fullscreen
func _on_TransparencyCheckbox_pressed() -> void:
    bgTransparency = not bgTransparency
    OS.window_per_pixel_transparency_enabled = bgTransparency
    get_tree().get_root().set_transparent_background(bgTransparency)
    setSave()
func _on_AlwaysOnTopCheckbox_pressed() -> void:
    alwaysOnTop = not alwaysOnTop
    OS.set_window_always_on_top(alwaysOnTop)
    setSave()
func _on_Hours_gui_input(event: InputEvent) -> void:
    if get_parent().input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $Hours.select_all()
        $Minutes.deselect()
        $Seconds.deselect()
        $Milliseconds.deselect()
func _on_Minutes_gui_input(event: InputEvent) -> void:
    if get_parent().input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $Minutes.select_all()
        $Hours.deselect()
        $Seconds.deselect()
        $Milliseconds.deselect()
func _on_Seconds_gui_input(event: InputEvent) -> void:
     if get_parent().input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $Seconds.select_all()
        $Hours.deselect()
        $Minutes.deselect()
        $Milliseconds.deselect()
func _on_Milliseconds_gui_input(event: InputEvent) -> void:
    if get_parent().input == 1 and (event is InputEventMouseButton or event is InputEventScreenTouch):
        $Milliseconds.select_all()
        $Seconds.deselect()
        $Hours.deselect()
        $Minutes.deselect()
