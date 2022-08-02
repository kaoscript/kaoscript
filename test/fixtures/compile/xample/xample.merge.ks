extern sealed class Array

impl Array {
	static merge(...args) {
		var dyn i = 0
		var dyn l = args.length
		while i < l && args[i] is not Array {
			++i
		}

		if i < l {
			var source: Array = args[i]

			while ++i < l {
				if args[i] is Array {
					for value in args[i] {
						source.pushUniq(value)
					}
				}
			}

			return source
		}
		else {
			return []
		}
	}
}