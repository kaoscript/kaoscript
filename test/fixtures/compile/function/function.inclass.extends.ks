func foobar() {
	class Shape {
		private {
			@color: String
		}
		constructor(@color)
	}

	class Rectangle extends Shape {
		constructor(@color) {
			super(color)
		}
	}
}