extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string
	}

    constructor(@color)

    draw(): string {
        return `I'm drawing with a \(this._color) pen.`
    }
}

class Rectangle extends Shape {
    draw() {
        return `\(super.draw()) I'm drawing a \(this._color) rectangle.`
    }
}

var dyn r = new Rectangle('black')

console.log(r.draw())