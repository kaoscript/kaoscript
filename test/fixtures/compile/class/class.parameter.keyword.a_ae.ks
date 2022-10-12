extern console

class Foobar {
	private {
		_class: String?		= null
		_default: Number	= -1
	}
	foobar(@class, @default = 0) {
		console.log(@class, @default)
	}
}
