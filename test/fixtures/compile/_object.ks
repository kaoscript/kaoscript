require Helper, Type

extern sealed class Object {
}

impl Object {
	static {
		map(object: object, iterator: func) {
			let results = []
			
			for item, index of object {
				results.push(iterator(item, index))
			}
			
			return results
		}
		
		map(object: object, iterator: func, condition: func) {
			let results = []
			
			for item, index of object {
				results.push(iterator(item, index)) if condition(item, index)
			}
			
			return results
		}
	}
}

export Object