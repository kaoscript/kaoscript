class Foobar {
	isNamed() => false
}

class Quxbaz extends Foobar {
	foobar(x: Foobar) {
		if x is not Quxbaz || !x.isNamed() {
			return false
		}

		var name = x.name()
		// if !x.isNamed() {
		// }
	}
	isNamed() => true
	name(): String => 'quxbaz'
}