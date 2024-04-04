#![libstd(off)]

extern system class Array

impl Array {
	static merge(...args) {
		var dyn i = 0
		var dyn l = args.length
		while i < l && args[i] is not Array {
			i += 1
		}

		if i < l {
			var source = args[i]:!(Array)

			i += 1

			while i < l {
				if args[i] is Array {
					for var value in args[i] {
						source.pushUniq(value)
					}
				}

				i += 1
			}

			return source
		}
		else {
			return []
		}
	}
}