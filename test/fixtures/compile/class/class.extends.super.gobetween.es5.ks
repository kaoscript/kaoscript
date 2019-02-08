#![format(classes='es5', functions='es5', parameters='es5', spreads='es5')]

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

let r = new Rectangle('black')

console.log(r.draw())