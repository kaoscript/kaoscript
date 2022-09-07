impl Dictionary {
	static {
		clone(dict: Dictionary): Dictionary {
			var dyn clone = {}

			return clone
		}
	}
}

func foobar(value?) => Dictionary.clone(value)