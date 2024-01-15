class ClassA {
	private {
		@x		= null
	}
	foobar() {
		this.x()
	}
	x() => @x
	x(@x) => this
}