require {
	class Ellipse

	func filterRotate(): Boolean
}

var shape = Ellipse.new(10, 20)
	..rotation = 45 * Math.PI / 180 if filterRotate()
	..color = 'rgb(0,129,198)'
	..outlineWidth = 0