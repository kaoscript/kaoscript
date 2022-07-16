class Shape {
	private {
		@name: String
	}
	constructor() {
		this('circle')
	}
	constructor(@name)
}

class Foobar extends Shape {
	private {
		_color: String
	}
	constructor(@color) {
		super('foobar')
	}
	constructor(@name) {
		super(@name)

		@color = 'red'
	}
}