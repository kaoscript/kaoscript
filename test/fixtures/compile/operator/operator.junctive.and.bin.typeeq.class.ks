class ClassA {
}

class ClassB extends ClassA {
}

func foobar(x) {
	if x is ClassA & ClassB {
	}

	if x is ClassA && x is ClassB {
	}
}