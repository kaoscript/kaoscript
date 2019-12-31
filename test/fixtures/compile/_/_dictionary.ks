extern systemic class Dictionary {
}

impl Dictionary {
	static {
		map(dict: Dictionary, iterator: Function) {
			let results = []

			for item, index of dict {
				results.push(iterator(item, index))
			}

			return results
		}

		map(dict: Dictionary, iterator: Function, condition: Function) {
			let results = []

			for item, index of dict when condition(item, index) {
				results.push(iterator(item, index))
			}

			return results
		}
	}
}

export Dictionary