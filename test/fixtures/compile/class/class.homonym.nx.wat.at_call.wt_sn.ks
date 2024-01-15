class ClassA {
	private {
		@x: String?		= null
	}
	foobar() {
		@x()
	}
	x() => @x
	x(@x) => this
}