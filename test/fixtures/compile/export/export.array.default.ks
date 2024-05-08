#[rules(non-exhaustive)]
extern system class Array {
	length: Number
}

impl Array {
	static {
		map(array: array, iterator: func) {
			var dyn results = []

			for var item, index in array {
				results.push(iterator(item, index))
			}

			return results
		}

		map(array: array, iterator: func, condition: func) {
			var dyn results = []

			for var item, index in array {
				results.push(iterator(item, index)) if condition(item, index)
			}

			return results
		}
	}

	last(index: Number = 1) {
		return if this.length != 0 set this[this.length - index] else null
	}
}

export Array