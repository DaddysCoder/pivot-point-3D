extends CanvasLayer
## Minimal interaction prompt — field-orders tone, not web-card UI.


@onready var label: Label = $Root/PromptLabel


func _ready() -> void:
	label.text = ""
	label.visible = false


func set_prompt(text: String) -> void:
	if text.is_empty():
		label.visible = false
		label.text = ""
	else:
		label.text = "[E]  %s" % text
		label.visible = true
