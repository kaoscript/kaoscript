extern console

import '../_/_string'

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
		let fragments = ''

		for const line in text.lines() {

		}

		return fragments
	}
}

let r = new Rectangle('black')

console.log(`\(r.draw('foo\nbar'))`)

export Shape, Rectangle