enum Accessibility {
	Internal = 1
	Private
	Protected
	Public
}

func foobar(data) {
	var access: Accessibility = Accessibility(data) ?? .Public
}