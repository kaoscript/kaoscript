extern system class Object {
}

impl Object {
	static {
		map(dict: Object, iterator: Function) {
			var dyn results = []

			for item, index of dict {
				results.push(iterator(item, index))
			}

			return results
		}

		map(dict: Object, iterator: Function, condition: Function) {
			var dyn results = []

			for item, index of dict when condition(item, index) {
				results.push(iterator(item, index))
			}

			return results
		}
	}
}

export Object