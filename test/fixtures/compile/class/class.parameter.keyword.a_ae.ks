extern console

class Foobar {
	private {
		_class: String?
		_default: Number
	}
	foobar(@class, @default = 0) {
		console.log(@class, @default)
	}
}
