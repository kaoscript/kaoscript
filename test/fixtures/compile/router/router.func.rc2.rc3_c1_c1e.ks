class ClassA {
}

class ClassB extends ClassA {
}

class ClassC extends ClassA {
}

func foobar(...args: ClassB) {
	return 0
}
func foobar(...args: ClassC, x: ClassA, y: ClassA) {
	return 1
}