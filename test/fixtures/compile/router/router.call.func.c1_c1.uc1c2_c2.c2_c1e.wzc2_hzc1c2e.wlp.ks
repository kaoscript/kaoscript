class ClassA {
	a: Number = 0
}

class ClassB {
	nodes: Object<Classes> = {}
}

type Classes = ClassA | ClassB

func foobar(x: ClassB, y: Classes) {
	for var node of x.nodes {
		quxbaz(node, y)
	}
}

func quxbaz(x: ClassA, y: ClassA) {
}

func quxbaz(x: ClassA | ClassB, y: ClassB) {
}

func quxbaz(x: ClassB, y: ClassA) {
}