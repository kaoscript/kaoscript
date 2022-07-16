class ClassA {
}
class ClassB {
}

func foobar(a: ClassA | ClassB) {
	quxbaz(a, 0)
}

func quxbaz(a: ClassA | ClassB, y: String) {
}

func quxbaz(x: ClassA, y: Number) {
}
func quxbaz(x: ClassB, y: Number) {
}