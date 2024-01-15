class ClassA {
	private {
		x		= null
	}
}

class ClassB extends ClassA {
	x() => @x
	x(@x) => this
}