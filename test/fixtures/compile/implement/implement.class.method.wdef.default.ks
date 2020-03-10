func defaultMessage(): String => 'Hello!'

class Shape {
	draw(text: String = defaultMessage()): String => text
}

impl Shape {
	draw2(text: String = defaultMessage()): String => `\(text) I'm drawing a new shape.`
}

export Shape