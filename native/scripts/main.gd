extends Node3D

const VERSION := "0.2.0-native-alpha"
const TARGET_FPS := 30
const CYCLE_DURATION := 88.0
const QUALITY_NAMES := ["SAFE", "STANDARD", "INSTALLATION"]
const QUALITY_CONFIG := [
    {"masses": 8, "links": 10, "sphere_radial": 12, "sphere_rings": 6, "shadow": false},
    {"masses": 12, "links": 18, "sphere_radial": 18, "sphere_rings": 9, "shadow": true},
    {"masses": 16, "links": 26, "sphere_radial": 24, "sphere_rings": 12, "shadow": true},
]

const PALETTES := [
    {
        "name": "OXIDISED BRONZE",
        "body": Color("5d3b2a"),
        "link": Color("38221a"),
        "light": Color("d6b07b"),
        "metallic": 0.82,
        "roughness": 0.56,
    },
    {
        "name": "CHARRED IRON",
        "body": Color("242322"),
        "link": Color("111111"),
        "light": Color("cc764b"),
        "metallic": 0.68,
        "roughness": 0.78,
    },
    {
        "name": "ASHEN PORCELAIN",
        "body": Color("8a8174"),
        "link": Color("4f4a43"),
        "light": Color("e6d8bd"),
        "metallic": 0.08,
        "roughness": 0.49,
    },
    {
        "name": "BURIED MINERAL",
        "body": Color("293b37"),
        "link": Color("162320"),
        "light": Color("8bb3a2"),
        "metallic": 0.42,
        "roughness": 0.71,
    },
]

var rng := RandomNumberGenerator.new()
var seed_value := 0
var elapsed := 0.0
var cycle_elapsed := 0.0
var generation := 1
var running := true
var ui_visible := true
var quality_index := 1
var low_fps_seconds := 0.0
var status_seconds := 0.0
var intro_seconds := 5.5

var sculpture_root: Node3D
var mass_nodes: Array = []
var mass_types: Array = []
var link_nodes: Array = []
var link_pairs: Array = []
var current_positions: Array = []
var gene_a: Array = []
var gene_b: Array = []
var palette_a: Dictionary
var palette_b: Dictionary

var body_material: StandardMaterial3D
var link_material: StandardMaterial3D
var floor_material: StandardMaterial3D
var sphere_mesh: SphereMesh
var capsule_mesh: CapsuleMesh
var box_mesh: BoxMesh
var cylinder_mesh: CylinderMesh

var camera: Camera3D
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var world_environment: WorldEnvironment
var ui_layer: CanvasLayer
var title_label: Label
var meta_label: Label
var state_label: Label
var help_label: Label
var status_label: Label
var intro_panel: CenterContainer

func _ready() -> void:
    Engine.max_fps = TARGET_FPS
    DisplayServer.window_set_title("FEROMORPH Native")
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

    seed_value = int(Time.get_unix_time_from_system()) ^ int(Time.get_ticks_usec())
    rng.seed = seed_value

    _build_environment()
    _build_stage()
    _build_ui()
    _rebuild_sculpture()
    _show_status("NATIVE ENGINE ONLINE", 3.0)

func _build_environment() -> void:
    world_environment = WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.004, 0.004, 0.005)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.13, 0.14, 0.16)
    environment.ambient_light_energy = 0.62
    world_environment.environment = environment
    add_child(world_environment)

    key_light = DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-47.0, -38.0, 0.0)
    key_light.light_color = Color("d4b887")
    key_light.light_energy = 2.25
    key_light.shadow_enabled = true
    add_child(key_light)

    fill_light = OmniLight3D.new()
    fill_light.position = Vector3(-3.2, 1.4, 2.8)
    fill_light.light_color = Color("7d9d99")
    fill_light.light_energy = 4.0
    fill_light.omni_range = 10.0
    fill_light.shadow_enabled = false
    add_child(fill_light)

    camera = Camera3D.new()
    camera.fov = 42.0
    camera.near = 0.08
    camera.far = 60.0
    camera.current = true
    add_child(camera)

func _build_stage() -> void:
    sculpture_root = Node3D.new()
    sculpture_root.name = "LivingSculpture"
    add_child(sculpture_root)

    floor_material = StandardMaterial3D.new()
    floor_material.albedo_color = Color(0.022, 0.022, 0.024)
    floor_material.metallic = 0.08
    floor_material.roughness = 0.91

    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(28.0, 28.0)
    var floor_instance := MeshInstance3D.new()
    floor_instance.name = "Ground"
    floor_instance.mesh = floor_mesh
    floor_instance.material_override = floor_material
    floor_instance.position.y = -2.55
    add_child(floor_instance)

func _build_ui() -> void:
    ui_layer = CanvasLayer.new()
    ui_layer.layer = 20
    add_child(ui_layer)

    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_layer.add_child(root)

    title_label = Label.new()
    title_label.text = "FEROMORPH"
    title_label.position = Vector2(30, 24)
    title_label.add_theme_font_size_override("font_size", 26)
    title_label.add_theme_color_override("font_color", Color("d8c9aa"))
    root.add_child(title_label)

    meta_label = Label.new()
    meta_label.position = Vector2(32, 62)
    meta_label.add_theme_font_size_override("font_size", 11)
    meta_label.add_theme_color_override("font_color", Color(0.62, 0.58, 0.49))
    root.add_child(meta_label)

    state_label = Label.new()
    state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    state_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    state_label.position = Vector2(-330, 30)
    state_label.size = Vector2(300, 28)
    state_label.add_theme_font_size_override("font_size", 13)
    state_label.add_theme_color_override("font_color", Color("c4b38f"))
    root.add_child(state_label)

    help_label = Label.new()
    help_label.text = "N  NEW GENESIS     P  PAUSE     F  FULLSCREEN     Q  QUALITY     S  CAPTURE     H  INTERFACE"
    help_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    help_label.position = Vector2(30, -44)
    help_label.size = Vector2(-60, 24)
    help_label.add_theme_font_size_override("font_size", 10)
    help_label.add_theme_color_override("font_color", Color(0.46, 0.44, 0.39))
    root.add_child(help_label)

    status_label = Label.new()
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    status_label.position = Vector2(0, -82)
    status_label.size = Vector2(0, 26)
    status_label.add_theme_font_size_override("font_size", 12)
    status_label.add_theme_color_override("font_color", Color("d8c9aa"))
    root.add_child(status_label)

    intro_panel = CenterContainer.new()
    intro_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    intro_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(intro_panel)

    var intro_box := VBoxContainer.new()
    intro_box.alignment = BoxContainer.ALIGNMENT_CENTER
    intro_panel.add_child(intro_box)

    var intro_title := Label.new()
    intro_title.text = "FEROMORPH"
    intro_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intro_title.add_theme_font_size_override("font_size", 46)
    intro_title.add_theme_color_override("font_color", Color("d8c9aa"))
    intro_box.add_child(intro_title)

    var intro_subtitle := Label.new()
    intro_subtitle.text = "AN AUTONOMOUS NATIVE SCULPTURE"
    intro_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intro_subtitle.add_theme_font_size_override("font_size", 11)
    intro_subtitle.add_theme_color_override("font_color", Color(0.52, 0.48, 0.41))
    intro_box.add_child(intro_subtitle)

func _rebuild_sculpture() -> void:
    for child in sculpture_root.get_children():
        child.queue_free()

    mass_nodes.clear()
    mass_types.clear()
    link_nodes.clear()
    link_pairs.clear()
    current_positions.clear()

    var config: Dictionary = QUALITY_CONFIG[quality_index]
    var mass_count: int = config["masses"]
    var link_count: int = config["links"]

    body_material = StandardMaterial3D.new()
    body_material.albedo_color = PALETTES[0]["body"]
    body_material.metallic = 0.7
    body_material.roughness = 0.6

    link_material = StandardMaterial3D.new()
    link_material.albedo_color = PALETTES[0]["link"]
    link_material.metallic = 0.74
    link_material.roughness = 0.66

    sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 1.0
    sphere_mesh.height = 2.0
    sphere_mesh.radial_segments = config["sphere_radial"]
    sphere_mesh.rings = config["sphere_rings"]

    capsule_mesh = CapsuleMesh.new()
    capsule_mesh.radius = 0.72
    capsule_mesh.height = 2.0
    capsule_mesh.radial_segments = config["sphere_radial"]
    capsule_mesh.rings = config["sphere_rings"]

    box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(1.6, 1.6, 1.6)

    cylinder_mesh = CylinderMesh.new()
    cylinder_mesh.top_radius = 1.0
    cylinder_mesh.bottom_radius = 1.0
    cylinder_mesh.height = 2.0
    cylinder_mesh.radial_segments = max(8, int(config["sphere_radial"] * 0.66))

    for i in range(mass_count):
        var mass := MeshInstance3D.new()
        mass.name = "Mass_%02d" % i
        var mesh_type := rng.randi_range(0, 9)
        if mesh_type <= 5:
            mass.mesh = sphere_mesh
            mass_types.append(0)
        elif mesh_type <= 7:
            mass.mesh = capsule_mesh
            mass_types.append(1)
        else:
            mass.mesh = box_mesh
            mass_types.append(2)
        mass.material_override = body_material
        mass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if config["shadow"] else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        sculpture_root.add_child(mass)
        mass_nodes.append(mass)
        current_positions.append(Vector3.ZERO)

    for i in range(link_count):
        var link := MeshInstance3D.new()
        link.name = "Ligament_%02d" % i
        link.mesh = cylinder_mesh
        link.material_override = link_material
        link.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if config["shadow"] else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        sculpture_root.add_child(link)
        link_nodes.append(link)

    gene_a = _generate_gene(mass_count)
    gene_b = _generate_gene(mass_count)
    _generate_link_pairs(mass_count, link_count)
    palette_a = PALETTES[rng.randi_range(0, PALETTES.size() - 1)].duplicate()
    palette_b = PALETTES[rng.randi_range(0, PALETTES.size() - 1)].duplicate()
    cycle_elapsed = 0.0
    generation = 1
    _show_status("QUALITY  %s" % QUALITY_NAMES[quality_index], 2.5)

func _generate_gene(count: int) -> Array:
    var gene: Array = []
    var vertical_bias: float = rng.randf_range(-0.22, 0.22)
    var turn: float = rng.randf_range(-PI, PI)

    for i in range(count):
        var fi: float = float(i)
        var core_weight: float = 0.18 if i < 3 else 1.0
        var angle: float = turn + TAU * fi / maxf(1.0, float(count)) + rng.randf_range(-0.66, 0.66)
        var radial: float = rng.randf_range(0.42, 1.72) * core_weight
        var y: float = rng.randf_range(-1.55, 1.5) + vertical_bias
        if i == 0:
            y = rng.randf_range(-0.45, 0.45)

        var position: Vector3 = Vector3(cos(angle) * radial, y, sin(angle) * radial)
        var size: float = rng.randf_range(0.48, 0.95)
        var scale_value: Vector3 = Vector3(
            size * rng.randf_range(0.62, 1.34),
            size * rng.randf_range(0.68, 1.58),
            size * rng.randf_range(0.62, 1.34)
        )
        if mass_types[i] == 2:
            scale_value *= rng.randf_range(0.65, 0.86)

        gene.append({
            "position": position,
            "scale": scale_value,
            "rotation": Quaternion.from_euler(Vector3(
                rng.randf_range(-PI, PI),
                rng.randf_range(-PI, PI),
                rng.randf_range(-PI, PI)
            )),
            "phase": rng.randf_range(0.0, TAU),
            "drift": rng.randf_range(0.035, 0.12),
            "rupture": rng.randf_range(0.12, 0.55),
        })

    return gene

func _generate_link_pairs(mass_count: int, link_count: int) -> void:
    link_pairs.clear()
    for i in range(link_count):
        var a := i % mass_count
        var b: int
        if i < mass_count:
            b = (i + 1) % mass_count
        else:
            b = rng.randi_range(0, mass_count - 1)
            if b == a:
                b = (b + 2) % mass_count
        link_pairs.append({
            "a": a,
            "b": b,
            "thickness": rng.randf_range(0.075, 0.18),
            "phase": rng.randf_range(0.0, TAU),
        })

func _process(delta: float) -> void:
    if running:
        elapsed += delta
        cycle_elapsed += delta
        if cycle_elapsed >= CYCLE_DURATION:
            cycle_elapsed -= CYCLE_DURATION
            gene_a = gene_b
            gene_b = _generate_gene(mass_nodes.size())
            palette_a = palette_b
            palette_b = PALETTES[rng.randi_range(0, PALETTES.size() - 1)].duplicate()
            generation += 1
            _generate_link_pairs(mass_nodes.size(), link_nodes.size())

    var phase := cycle_elapsed / CYCLE_DURATION
    var morph := _smoothstep(0.05, 0.94, phase)
    var stillness := _window(phase, 0.29, 0.47)
    var rupture := _window(phase, 0.61, 0.79)
    var movement := 1.0 - stillness * 0.9

    _update_materials(morph)
    _update_masses(morph, movement, rupture)
    _update_links(rupture)
    _update_camera(delta)
    _update_ui(phase, stillness, rupture)
    _update_performance(delta)

    if intro_seconds > 0.0:
        intro_seconds -= delta
        intro_panel.modulate.a = clamp(intro_seconds - 0.5, 0.0, 1.0)
        intro_panel.visible = intro_panel.modulate.a > 0.001

    if status_seconds > 0.0:
        status_seconds -= delta
        status_label.modulate.a = clamp(status_seconds, 0.0, 1.0)
    else:
        status_label.text = ""

func _update_materials(morph: float) -> void:
    body_material.albedo_color = palette_a["body"].lerp(palette_b["body"], morph)
    body_material.metallic = lerpf(float(palette_a["metallic"]), float(palette_b["metallic"]), morph)
    body_material.roughness = lerpf(float(palette_a["roughness"]), float(palette_b["roughness"]), morph)
    link_material.albedo_color = palette_a["link"].lerp(palette_b["link"], morph)
    link_material.metallic = clampf(body_material.metallic + 0.05, 0.0, 1.0)
    link_material.roughness = clampf(body_material.roughness + 0.08, 0.0, 1.0)
    key_light.light_color = palette_a["light"].lerp(palette_b["light"], morph)

func _update_masses(morph: float, movement: float, rupture: float) -> void:
    for i in range(mass_nodes.size()):
        var node: MeshInstance3D = mass_nodes[i]
        var a: Dictionary = gene_a[i]
        var b: Dictionary = gene_b[i]
        var position: Vector3 = a["position"].lerp(b["position"], morph)
        var scale_value: Vector3 = a["scale"].lerp(b["scale"], morph)
        var phase_value: float = lerpf(float(a["phase"]), float(b["phase"]), morph)
        var drift_value: float = lerpf(float(a["drift"]), float(b["drift"]), morph)

        var drift: Vector3 = Vector3(
            sin(elapsed * 0.21 + phase_value),
            cos(elapsed * 0.17 + phase_value * 1.3),
            sin(elapsed * 0.13 - phase_value * 0.7)
        ) * drift_value * movement
        position += drift

        var outward: Vector3 = position.normalized() if position.length() > 0.01 else Vector3.UP
        position += outward * rupture * lerpf(float(a["rupture"]), float(b["rupture"]), morph)

        var breath: float = 1.0 + sin(elapsed * 0.16 + phase_value) * 0.035 * movement
        scale_value *= breath

        node.position = position
        node.scale = scale_value
        var base_rotation: Quaternion = a["rotation"].slerp(b["rotation"], morph)
        var micro_rotation: Quaternion = Quaternion(Vector3.UP, sin(elapsed * 0.07 + phase_value) * 0.035 * movement)
        node.quaternion = base_rotation * micro_rotation
        current_positions[i] = position

func _update_links(rupture: float) -> void:
    for i in range(link_nodes.size()):
        var node: MeshInstance3D = link_nodes[i]
        var data: Dictionary = link_pairs[i]
        var a: Vector3 = current_positions[data["a"]]
        var b: Vector3 = current_positions[data["b"]]
        var direction := b - a
        var length := direction.length()

        if length < 0.08 or length > 3.8 + rupture * 0.7:
            node.visible = false
            continue

        node.visible = true
        node.position = (a + b) * 0.5
        node.quaternion = Quaternion(Vector3.UP, direction.normalized())
        var pulse: float = 0.84 + sin(elapsed * 0.23 + float(data["phase"])) * 0.12
        var thickness: float = float(data["thickness"]) * pulse * (1.0 - rupture * 0.34)
        node.scale = Vector3(thickness, length * 0.5, thickness)

func _update_camera(_delta: float) -> void:
    var camera_angle: float = elapsed * 0.026 + float(seed_value % 1000) * 0.001
    var radius: float = 8.2 + sin(elapsed * 0.041) * 0.38
    camera.position = Vector3(
        sin(camera_angle) * radius,
        0.55 + sin(elapsed * 0.031 + 1.2) * 0.58,
        cos(camera_angle) * radius
    )
    camera.look_at(Vector3(0.0, -0.22, 0.0), Vector3.UP)
    fill_light.position = Vector3(
        -sin(camera_angle * 0.72) * 3.5,
        1.6 + sin(elapsed * 0.07) * 0.4,
        cos(camera_angle * 0.72) * 3.5
    )

func _update_ui(phase: float, stillness: float, rupture: float) -> void:
    var state := "FORMATION"
    if not running:
        state = "SUSPENDED"
    elif stillness > 0.55:
        state = "STILLNESS"
    elif rupture > 0.42:
        state = "RUPTURE"
    elif phase > 0.82:
        state = "METAMORPHOSIS"

    var fps: int = Engine.get_frames_per_second()
    meta_label.text = "SEED %s  ·  GENERATION %02d  ·  %s  ·  %d FPS" % [
        str(seed_value), generation, QUALITY_NAMES[quality_index], fps
    ]
    state_label.text = "%s  /  %s" % [state, str(palette_b.get("name", "MATTER"))]

func _update_performance(delta: float) -> void:
    var fps: int = Engine.get_frames_per_second()
    if fps > 0 and fps < 19:
        low_fps_seconds += delta
    else:
        low_fps_seconds = maxf(0.0, low_fps_seconds - delta * 0.5)

    if low_fps_seconds > 5.0 and quality_index > 0:
        quality_index -= 1
        low_fps_seconds = 0.0
        _rebuild_sculpture()
        _show_status("PERFORMANCE SAFEGUARD  ·  %s" % QUALITY_NAMES[quality_index], 4.0)

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return
    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return

    match key_event.keycode:
        KEY_N:
            _new_genesis()
        KEY_P, KEY_SPACE:
            running = not running
            _show_status("TIME RESUMED" if running else "TIME SUSPENDED", 2.0)
        KEY_F:
            _toggle_fullscreen()
        KEY_Q:
            quality_index = (quality_index + 1) % QUALITY_NAMES.size()
            _rebuild_sculpture()
        KEY_1:
            quality_index = 0
            _rebuild_sculpture()
        KEY_2:
            quality_index = 1
            _rebuild_sculpture()
        KEY_3:
            quality_index = 2
            _rebuild_sculpture()
        KEY_H:
            ui_visible = not ui_visible
            title_label.visible = ui_visible
            meta_label.visible = ui_visible
            state_label.visible = ui_visible
            help_label.visible = ui_visible
            status_label.visible = ui_visible
        KEY_S:
            _capture_frame()
        KEY_ESCAPE:
            if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _new_genesis() -> void:
    seed_value = int(Time.get_unix_time_from_system()) ^ int(Time.get_ticks_usec())
    rng.seed = seed_value
    gene_a = _generate_gene(mass_nodes.size())
    gene_b = _generate_gene(mass_nodes.size())
    palette_a = PALETTES[rng.randi_range(0, PALETTES.size() - 1)].duplicate()
    palette_b = PALETTES[rng.randi_range(0, PALETTES.size() - 1)].duplicate()
    _generate_link_pairs(mass_nodes.size(), link_nodes.size())
    elapsed = 0.0
    cycle_elapsed = 0.0
    generation = 1
    _show_status("NEW GENESIS  ·  %s" % str(seed_value), 3.0)

func _toggle_fullscreen() -> void:
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _capture_frame() -> void:
    var image: Image = get_viewport().get_texture().get_image()
    var stamp: String = Time.get_datetime_string_from_system().replace(":", "-")
    var path: String = "user://FEROMORPH_%s_%s.png" % [str(seed_value), stamp]
    var result: Error = image.save_png(path)
    if result == OK:
        _show_status("CAPTURE SAVED  ·  %s" % ProjectSettings.globalize_path(path), 5.0)
    else:
        _show_status("CAPTURE FAILED", 3.0)

func _show_status(message: String, seconds: float) -> void:
    status_label.text = message
    status_label.modulate.a = 1.0
    status_seconds = seconds

func _smoothstep(edge0: float, edge1: float, value: float) -> float:
    var x: float = clampf((value - edge0) / (edge1 - edge0), 0.0, 1.0)
    return x * x * (3.0 - 2.0 * x)

func _window(value: float, start: float, finish: float) -> float:
    var middle: float = (start + finish) * 0.5
    var up: float = _smoothstep(start, middle, value)
    var down: float = 1.0 - _smoothstep(middle, finish, value)
    return minf(up, down)
