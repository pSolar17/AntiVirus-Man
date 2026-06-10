extends Enemy

# Spinner Boss enemy script.

func attack2():
	$Laser2_1.look_at(GameManager.player.global_position)
	$Laser2_1.fire()
	await get_tree().create_timer(1.0).timeout
	$Laser2_2.look_at(GameManager.player.global_position)
	$Laser2_2.fire()
	await get_tree().create_timer(1.0).timeout
	$Laser2_3.look_at(GameManager.player.global_position)
	$Laser2_3.fire()
	await get_tree().create_timer(1.0).timeout

func take_damage(value : float):
	super.take_damage(value)
	var spr_material : Material = $Sprite.material
	if spr_material is ShaderMaterial:
		spr_material.set_shader_parameter("enabled", true)
		await get_tree().create_timer(4.0/60.0).timeout
		spr_material.set_shader_parameter("enabled", false)
