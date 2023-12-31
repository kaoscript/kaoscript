class ClassA {
	private {
		@x: Function?		= null
	}
	foobar() {
		@x()
	}
	x() => @x
	x(@x) => this
}