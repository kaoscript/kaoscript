class Shape {
	private {
		_color: string = ''
		_type: string = ''
	}
	
	static registerCircle() {
		impl Shape {
			makeCircle(color: string) -> Shape => new Shape('circle', color)
		}
	}
	
	Shape(@type: string, @color: string)
}