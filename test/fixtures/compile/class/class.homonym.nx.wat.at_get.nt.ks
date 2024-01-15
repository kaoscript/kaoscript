class ClassA {
	private {
		@x		= null
	}
	foobar() {
		var x = @x
	}
	x() => @x
	x(@x) => this
}