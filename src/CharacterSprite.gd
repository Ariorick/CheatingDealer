extends Sprite


export(Texture) var alt_texture: Texture
export(Texture) var win_texture: Texture

onready var normal_texture = texture

func alternate(alternate: bool, win: bool):
	texture = alt_texture if alternate else normal_texture
	if alternate and win and win_texture != null:
		texture = win_texture
	
	scale = Vector2(0.54, 0.54) if alternate else Vector2(0.5, 0.5)
