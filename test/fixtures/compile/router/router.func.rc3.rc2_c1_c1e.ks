class ClassA {
}

class ClassB extends ClassA {
}

class ClassC extends ClassA {
}

func foobar(...args: ClassC) {
	return 0
}
func foobar(...args: ClassB, x: ClassA, y: ClassA) {
	return 1
}