extends Area2D

var parent : Node = get_parent()
@export var width : int = 300
@export var height : int = 400
@export var damage : int = 50
@export var angle : int = 90
@export var base_kb : int = 100
@export var kb_scaling : int = 2
@export var duration : int = 1500
@export var hitlag_modifier : int = 1
@export var type : String = 'normal'
@export var angle_flipper = 0
@onready var hitbox : CollisionShape2D = get_node("Hitbox_Shape")
@onready var parentState = get_parent().selfState

var knockbackVal
var framez : float = 0.0
var player_list : Array = []



func set_parameters(w,h,d,a,b_kb,kb_s,dur,t,p,af, hit,parent = get_parent()):
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)
	width= w
	height = h
	damage = d
	angle = a
	base_kb = b_kb
	kb_scaling = kb_s
	duration = dur
	type = t
	self.position = p
	hitlag_modifier = hit
	angle_flipper = af
	update_extents()
	#connect("body_entered", self, "Hitbox_Collide")
	set_physics_process(true)
	
func update_extents():
	hitbox.shape.extents = Vector2(width,height)
	
func _ready():
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	pass
	
func _physics_process(delta):
	if framez<duration:
		framez += floor(delta * 60)
	elif framez == duration:
		queue_free()
		return
	if get_parent().selfState != parentState:
		Engine.time_scale = 1
		queue_free()
		return
