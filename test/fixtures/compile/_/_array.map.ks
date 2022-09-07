require system class Array

impl Array {
	static {
		map(array: array, iterator: func) {
			var dyn results = []

			for item, index in array {
				results.push(iterator(item, index))
			}

			return results
		}

		map(array: array, iterator: func, condition: func) {
			var dyn results = []

			for item, index in array {
				results.push(iterator(item, index)) if condition(item, index)
			}

			return results
		}
	}
}

export Array