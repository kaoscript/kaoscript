class ClassA {
}

class ClassB extends ClassA {
}

class ClassC extends ClassA {
}

func foobar(...args: ClassA) {
	return 0
}
func foobar(...args: ClassB) {
	return 1
}
func foobar(...args: ClassB, x: ClassC, y: ClassC) {
	return 2
}