#![format(classes='es5', functions='es5')]

extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string
	}
	
    constructor(@color)
    
    pen(): string {
        return `I'm drawing with a \(this._color) pen.`
    }
}

class Rectangle extends Shape {
    draw() {
        return `\(super.pen()) I'm drawing a \(this._color) rectangle.`
    }
}

let r = new Rectangle('black')

console.log(r.draw())