class ClassA {
	foobar(): Number => 0
}

class ClassB extends ClassA {
	private {
		@element: ClassA = new ClassA()
	}
	alias {
		foobar = @element.foobar
	}
}

var a = new ClassA()
var b = new ClassB()

a.foobar()
b.foobar()

func foobar(a: ClassA) {
	a.foobar()
}