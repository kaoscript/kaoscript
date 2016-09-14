import Class, Type from @kaoscript/runtime/src/runtime.js

extern {
	final class Array
	final class Function
	final class Object
}

impl Array {
	static {
		map(array: array, iterator: func) {
			let results = []
			
			for item, index in array {
				results.push(iterator(item, index))
			}
			
			return results
		}
		
		map(array: array, iterator: func, condition: func) {
			let results = []
			
			for item, index in array {
				results.push(iterator(item, index)) if condition(item, index)
			}
			
			return results
		}
	}
}

impl Function {
	static {
		vcurry(self: func, bind?, ...args) {
			return func(...additionals) {
				return self.apply(bind, args.concat(additionals))
			}
		}
	}
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

export Array, Class, Function, Object, Type