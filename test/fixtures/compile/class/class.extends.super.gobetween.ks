extern console

class Shape {
	private {
		_color: String
	}

    constructor(@color)

    draw(): String {
        return `I'm drawing with a \(@color) pen.`
    }
}

class Quadrilateral extends Shape {
}

class Rectangle extends Quadrilateral {
    draw() {
        return `\(super.draw()) I'm drawing a \(@color) rectangle.`
    }
}

var dyn r = Rectangle.new('black')

console.log(r.draw())