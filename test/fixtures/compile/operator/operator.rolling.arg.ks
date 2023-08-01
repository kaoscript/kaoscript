require {
	class Ellipse

	func addShape(shape: Ellipse)
}

addShape(
	Ellipse.new(10, 20)
		..rotation = 45 * Math.PI / 180
		..color = 'rgb(0,129,198)'
		..outlineWidth = 0
)