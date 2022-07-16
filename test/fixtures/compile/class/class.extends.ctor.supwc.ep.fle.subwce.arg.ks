abstract class Shape {
	private {
		_name: String
	}
	constructor() {
		this('circle')
	}
	constructor(@name)
}

class Rectangle extends Shape {
	constructor() {
		super('rectangle')
	}
}

class Foobar extends Shape {
	constructor(color: String)
}