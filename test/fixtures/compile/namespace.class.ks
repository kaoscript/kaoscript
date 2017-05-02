namespace qux {
	class Foobar {
		private {
			_name: String
		}
		constructor(@name = 'john')
	}
	
	export Foobar
}

const x = new qux.Foobar()