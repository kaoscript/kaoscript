class ClassA {
}
class ClassB extends ClassA {
}

func foobar(mut x: ClassB) {
	if x ?= quxbaz()!! {
	}
}

func quxbaz(): ClassA? {
	return ClassB.new()
}