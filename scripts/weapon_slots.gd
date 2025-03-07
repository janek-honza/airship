extends Node3D

@onready var player = $".."

@onready var slot_1 = $weapon_slot_1
@onready var slot_2 = $weapon_slot_2
@onready var slot_3 = $weapon_slot_3
@onready var slot_4 = $weapon_slot_4
@onready var slot_5 = $weapon_slot_5
@onready var slot_6 = $weapon_slot_6
@onready var slot_7 = $weapon_slot_7
@onready var slot_8 = $weapon_slot_8

func _on_player_airship_type_switched() -> void:
	update_weapon_slots_position()

func update_weapon_slots_position():
	match player.airship_type:
		'small':
			slot_1.position = Vector3(0, -15, 11)
			slot_1.rotation = Vector3(0, 0, 0)
			slot_1.visible = true
		
		'medium':
			slot_1.position = Vector3(0, -25, 23)
			slot_1.rotation = Vector3(0, 0, 0)
		
		'big':
			slot_1.position = Vector3(0, -29, 17) #front
			slot_1.rotation = Vector3(0, 0, 0)
			slot_1.visible = true
			
			slot_2.position = Vector3(2, -29, 14) #left front
			slot_2.rotation = Vector3(0, 90, 0)
			slot_2.visible = true
			
			slot_3.position = Vector3(2, -30, 2) #left middle
			slot_3.rotation = Vector3(0, 90, 0)
			slot_3.visible = true
			
			slot_4.position = Vector3(2, -29, -11) #left back
			slot_4.rotation = Vector3(0, 90, 0)
			slot_4.visible = true
			
			slot_5.position = Vector3(2, -29, -11) #back
			slot_5.rotation = Vector3(0, 90, 0)
			slot_5.visible = true
			
			slot_6.position = Vector3(0, -29, -20) #right back
			slot_6.rotation = Vector3(0, 180, 0)
			slot_6.visible = true
			
			slot_7.position = Vector3(-2, -30, 2) #right middle
			slot_7.rotation = Vector3(0, -90, 0)
			slot_7.visible = true
			
			slot_8.position = Vector3(-2, -29, 14) #right front
			slot_8.rotation = Vector3(0, -90, 0)
			slot_8.visible = true
		
		_:
			printerr("\nERROR: Airship type ", player.airship_type, "not implemented in weapon_slots.gd")
