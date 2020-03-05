class ClassA {
}

class ClassB extends ClassA {
}

func foobar(x) {
	if x is not ClassA | ClassB {
	}

	if x is not ClassA || x is not ClassB {
	}
}