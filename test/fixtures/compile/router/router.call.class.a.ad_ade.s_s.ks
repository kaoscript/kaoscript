class Master {
	private {
		a: String	= ''
	}
	foobar(a)
}
class Foobar extends Master {
	private {
		b: String
	}
	foobar(a = @a, b = @b) {
		return b
	}
}

const f = new Foobar()

f.foobar('', '')