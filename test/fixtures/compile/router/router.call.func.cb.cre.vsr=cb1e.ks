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

var x = SubClassA.new()

foobar(x)