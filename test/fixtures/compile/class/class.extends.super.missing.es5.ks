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

class Rectangle extends Shape {
    draw() {
        return `\(super.paint()) I'm drawing a \(@color) rectangle.`
    }
}

let r = new Rectangle('black')

console.log(r.draw())