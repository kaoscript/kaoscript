abstract class ClassA {
	private {
		@x: Number
	}
	constructor() {
	}
}

class ClassB extends ClassA {
	constructor() {
		super()

		@x = 0
	}
}