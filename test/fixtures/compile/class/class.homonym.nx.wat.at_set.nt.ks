class ClassA {
	private {
		@x		= null
	}
	foobar() {
		@x = 0
	}
	x() => @x
	x(@x) => this
}