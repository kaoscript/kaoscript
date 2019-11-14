class Foobar {
}

const $map = {
	default: Foobar
	foobar: Foobar
}

func foobar(name) {
	const clazz = $map[name] ?? $map.default

	return new clazz()
}