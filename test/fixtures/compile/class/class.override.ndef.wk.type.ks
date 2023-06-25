extern console

import '../_/_string.ks'

class Shape {
	private {
		_color: String
	}

	constructor(@color)

	draw(text: String): String {
		return @color
	}
}

class Rectangle extends Shape {
	constructor(@color) {
		super(color)
	}

	override draw(text) {
		var dyn fragments = ''

		for var line in text.lines() {

		}

		return fragments
	}
}

var dyn r = Rectangle.new('black')

console.log(`\(r.draw('foo\nbar'))`)

export Shape, Rectangle