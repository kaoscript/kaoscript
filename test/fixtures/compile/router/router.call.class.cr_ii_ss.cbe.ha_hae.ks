class ClassA {
	constructor(x: Number, y: Number) {
	}
	constructor(x: String, y: String) {
	}
}

class ClassB extends ClassA {
	constructor(x, y) {
		super(x, y)
	}
}