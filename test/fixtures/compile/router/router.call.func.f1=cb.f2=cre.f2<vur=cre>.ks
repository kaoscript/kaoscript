class SuperClass {
}

class SubClassA extends SuperClass {
}

class SubClassB extends SuperClass {
}

func foobar(x: SubClassA) {
	return 'sub'
}
func quxbaz(x: SuperClass) {
	return 'super'
}

var o = SuperClass.new()

quxbaz(o)