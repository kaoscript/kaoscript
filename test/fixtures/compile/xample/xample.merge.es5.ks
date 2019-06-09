#![format(variables='es5')]

extern sealed class Array

impl Array {
	static merge(...args) {
		let source

		let i = 0
		let l = args.length
		while i < l && !((source ?= args[i]) && source is Array) {
			++i
		}
		++i

		while i < l {
			if args[i] is Array {
				for value in args[i] {
					source.pushUniq(value)
				}
			}

			++i
		}

		return source
	}
}