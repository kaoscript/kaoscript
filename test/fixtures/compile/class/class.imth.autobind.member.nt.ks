class ClassA {
	private {
		@x = ClassB.new()
	}
	foobar() => @x
}

class ClassB {
	private {
		@x = 0
	}
	quxbaz() => @x
}

var x = ClassA.new()

var quxbaz = x.foobar().quxbaz

echo(quxbaz())