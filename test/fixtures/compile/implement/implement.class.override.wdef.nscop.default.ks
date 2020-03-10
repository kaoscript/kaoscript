class Shape {
	draw(text: String = 'Hello!'): String => text
}

impl Shape {
	override draw(text) => `\(text) I'm drawing a new shape.`
}

export Shape