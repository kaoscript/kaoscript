class ClassA {
	foobar(): Number => 0
}

class ClassB extends ClassA {
	private {
		@element: ClassA = ClassA.new()
	}
	proxy {
		foobar = @element.foobar
	}
}

var a = ClassA.new()
var b = ClassB.new()

a.foobar()
b.foobar()

func foobar(a: ClassA) {
	a.foobar()
}