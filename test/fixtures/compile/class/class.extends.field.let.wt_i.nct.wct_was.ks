abstract class ClassA {
	private {
		@x: Number
	}
}

class ClassB extends ClassA {
	constructor() {
		super()

		@x = 1
	}
}