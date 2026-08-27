class_name CharacterOptions
extends RefCounted
## Cosmetic options for the operator character creator (palette + headwear).
## Mirrors the field-palette naming from the 2D reference build.

const PALETTES := {
	"olive": Color(0.353, 0.420, 0.271),
	"slate": Color(0.290, 0.335, 0.384),
	"sand": Color(0.663, 0.565, 0.408),
	"ink": Color(0.165, 0.200, 0.251),
	"cobalt": Color(0.227, 0.333, 0.471),
	"rust": Color(0.541, 0.290, 0.196),
}

const HEADWEAR := ["none", "cap", "helm", "visor"]

const PALETTE_ORDER := ["olive", "slate", "sand", "ink", "cobalt", "rust"]


static func palette_color(id: String) -> Color:
	return PALETTES.get(id, PALETTES["olive"])
