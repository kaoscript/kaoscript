class Shape {
	private {
		_color: string = ''
		_type: string = ''
	}
	
	static {
		makeCircle(color: string): Shape => new Shape('circle', color)
		
		makeRectangle(color: string): Shape => new Shape('rectangle', color)
	}
	
	$create(@type: string, @color: string)
}

let r = Shape.makeRectangle('black')