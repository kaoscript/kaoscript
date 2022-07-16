abstract class Foobar {
	foobar() => false
	foobar(x): Boolean => false
}

class Quxbaz extends Foobar {
	foobar() => true
}