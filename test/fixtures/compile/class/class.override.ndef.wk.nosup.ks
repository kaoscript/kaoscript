extern console

class Rectangle {
	constructor(@color) {
		super(color)
	}

	override draw() {
		return `I'm drawing a \(@color) rectangle.`
	}
}

var dyn r = new Rectangle('black')

console.log(r.draw())