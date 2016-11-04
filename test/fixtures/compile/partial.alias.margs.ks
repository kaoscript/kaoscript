class Shape {
	Shape()
	
	draw(shape, color, canvas) -> string {
		return `I'm drawing a \(color) \(shape).`
	}
}

let shape = 'rectangle'
let color = 'blue'

impl Shape {
	`\(shape)`(canvas) as draw with shape, color
}