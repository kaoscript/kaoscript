require expect: func

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(prefix: String): String => `\(prefix)\(@color)`
}

class Rectangle extends Shape {
	draw(prefix: String): String => `\(prefix) I'm drawing a \(@color) rectangle.`
}

var dyn r = Rectangle.new('black')

expect(r.draw('Hello!')).to.equal(`Hello! I'm drawing a black rectangle.`)