class ClassA {
	private {
		@x		= null
	}
	foobar() {
		var x = this.x
	}
	x() => @x
	x(@x) => this
}