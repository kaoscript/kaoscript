class Shape {
	private {
		_color: string = ''
	}
	
	$create(@color: string)
}

let name := 'draw'
let shape = 'rectangle'

func draw(shape, canvas): string {
	return `I'm drawing a \(this._color) \(shape).`
}

impl Shape {
	`\(name)`(canvas) for draw with shape
}