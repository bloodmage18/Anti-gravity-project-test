@tool
extends Sprite2D


func _ready():
	pass

func _physics_process(_delta):
	_zoom_changed()

func _zoom_changed():
#	material.set("shader_parameter/y_zoom" , get_viewport().global_canvas_transform.y.y )
	material.set("shader_parameter/y_zoom" , get_viewport_transform().get_scale().y )
#	material.set_shader_param("y_zoom" , get_viewport_transform().get_scale().y)

func _on_water_item_rect_changed():
	material.set("shader_parameter/y_zoom" , scale )
	#material.set_shader_param("scale" , scale )

func _on_item_rect_changed():
	material.set("shader_parameter/y_zoom" , scale )
	#material.set_shader_param("scale" , scale )
