class Shape {
	private {
		_color: string = ''
		_type: string = ''
	}

	static {
		makeCircle(color: string): Shape => Shape.new('circle', color)

		makeRectangle(color: string): Shape => Shape.new('rectangle', color)
	}

	constructor(@type, @color)
}

var dyn r = Shape.makeRectangle('black')