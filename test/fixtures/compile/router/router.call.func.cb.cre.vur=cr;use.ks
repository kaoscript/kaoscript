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
func make(): SuperClass => SubClassA.new()

var o = if test() set make() else SuperClass.new()

foobar(o)