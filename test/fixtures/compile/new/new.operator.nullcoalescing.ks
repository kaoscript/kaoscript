class Foobar {
}

var $map = {
	default: Foobar
	foobar: Foobar
}

func foobar(name) {
	var clazz = $map[name] ?? $map.default

	return new clazz()
}