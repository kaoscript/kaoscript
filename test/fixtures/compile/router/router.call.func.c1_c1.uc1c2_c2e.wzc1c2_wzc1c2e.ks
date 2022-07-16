class ClassA {
	a: Number = 0
}

class ClassB {
	nodes: Dictionary<Classes> = {}
}

type Classes = ClassA | ClassB

func foobar(a: Classes, b: Classes) {
	quxbaz(a, b)
}

func quxbaz(x: ClassA, y: ClassA) {
}

func quxbaz(x: ClassA | ClassB, y: ClassB) {
}