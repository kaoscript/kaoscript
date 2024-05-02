class Foobar {
	foobar(value, flag: Boolean = false) {
	}
	foobar(value, name: String, flag: Boolean = false) {
	}
	foobar(value, data: Array, flag: Boolean = false) {
	}
}

class Quxbaz extends Foobar {
	override foobar(value, flag) {
	}
	override foobar(value, name, flag) {
	}
	foobar(value, from: Number, to: Number?, flag: Boolean?) {
	}
}