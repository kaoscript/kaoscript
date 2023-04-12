class Foobar {

}

class Quxbaz {
	private {
		_options = {
			class: Foobar
		}
	}
	new() {
		var foo = @options.class.new()
	}
}