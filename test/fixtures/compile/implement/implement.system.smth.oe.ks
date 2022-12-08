impl Object {
	static {
		clone(dict: Object): Object {
			var dyn clone = {}

			return clone
		}
	}
}

func foobar(value?) => Object.clone(value)