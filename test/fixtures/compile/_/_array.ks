extern system class Array {
	length: Number
	concat(...): Array
	indexOf(...): Number
	push(...)
	shift(): Any
	splice(...): Array
	unshift(...)
}

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

	last(index: Number = 1) {
		return this.length != 0 ? this[this.length - index] : null
	}
}

export Array