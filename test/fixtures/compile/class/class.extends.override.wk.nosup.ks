extern console

class Rectangle {
	constructor(@color) {
		super(color)
	}

	override draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

let r = new Rectangle('black')

console.log(r.draw())