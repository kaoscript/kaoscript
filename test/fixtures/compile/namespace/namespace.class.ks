namespace qux {
	class Foobar {
		private {
			_name: String
		}
		constructor(@name = 'john')
	}

	export Foobar
}

var x = new qux.Foobar()