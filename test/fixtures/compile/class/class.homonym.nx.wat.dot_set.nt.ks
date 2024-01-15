class ClassA {
	private {
		@x		= null
	}
	foobar() {
		this.x = 0
	}
	x() => @x
	x(@x) => this
}