#![format(variables='es5')]

extern sealed class Array

impl Array {
	static merge(...args) {
		let i = 0
		let l = args.length
		while i < l && args[i] is not Array {
			++i
		}

		if i < l {
			const source: Array = args[i]

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