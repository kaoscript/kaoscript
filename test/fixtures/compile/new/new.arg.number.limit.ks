import '../_/_number.ks'

class Foobar {
	private {
		@value: Number	= 0
	}
	constructor(@value) {
	}
	foobar() {
		var x = new Foobar(@value.limit(0, 255))
	}
}