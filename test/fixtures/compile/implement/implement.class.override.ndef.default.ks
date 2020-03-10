class Shape {
	draw(text: String): String => text
}

impl Shape {
	override draw(text) => `I'm drawing a new shape.`
}

export Shape