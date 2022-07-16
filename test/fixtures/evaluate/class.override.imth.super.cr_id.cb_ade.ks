require expect: func

class ClassA {
	foobar(x: Number = 0) => 0
}

class ClassB extends ClassA {
	foobar(x = 0) => super(x)
}

const b = new ClassB()

expect(b.foobar()).to.equals(0)