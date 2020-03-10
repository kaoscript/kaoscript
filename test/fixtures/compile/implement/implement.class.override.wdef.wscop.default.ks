func defaultMessage(): String => 'Hello!'

class Shape {
	draw(text: String = defaultMessage()): String => text
}

impl Shape {
	override draw(text) => `\(text) I'm drawing a new shape.`
}

export Shape