class ClassA {
	a: Number = 0
}

class ClassB {
}

func foobar(a: ClassA | ClassB, b: ClassA | ClassB) {
	quxbaz(a, b)
}

func quxbaz(x: ClassA, y: ClassA) {
}

func quxbaz(x: ClassA | ClassB, y: ClassB) {
}

func quxbaz(x: ClassB, y: ClassA) {
}