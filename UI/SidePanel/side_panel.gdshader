shader_type canvas_item;

uniform vec4 fill_color : source_color = vec4(1.0);   // #fff
uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float border_width = 2.0;   // en pixels
/*## Indispensable pour que les borders tombe juste, mettre a jours via script si besoin*/
uniform float node_width = 100.0;  
uniform float node_height = 100.0;  // mis à jour par script
uniform float extend = 100000.0;

varying float local_x;

void vertex() {
	local_x = VERTEX.x;
	if (VERTEX.y < node_height * 0.5) {
		VERTEX.y -= extend;
	} else {
		VERTEX.y += extend;
	}
}

void fragment() {
	if (local_x < border_width || local_x > node_width - border_width) {
		COLOR = border_color;
	} else {
		COLOR = fill_color;
	}
}