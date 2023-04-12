import '../_/_number.ks'

class Foobar {
	private {
		@value: Number	= 0
	}
	constructor(@value) {
	}
	foobar() {
		var x = Foobar.new(@value.limit(0, 255))
	}
}