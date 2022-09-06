class SuperClass {
}

class SubClassA extends SuperClass {
}

class SubClassB extends SuperClass {
}

func foobar(x: SubClassA) {
	return 'sub'
}
func foobar(x: SuperClass) {
	return 'super'
}

func test() => false
func make(): SuperClass => new SubClassA()

var o = test() ? new SuperClass() : make()

foobar(o)