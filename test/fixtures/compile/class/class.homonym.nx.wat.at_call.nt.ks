class ClassA {
	private {
		@x		= null
	}
	foobar() {
		@x()
	}
	x() => @x
	x(@x) => this
}