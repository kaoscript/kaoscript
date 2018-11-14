extern sealed class Array

impl Array {
	pluck(name) {
		let result = []
		
		let value
		for item in this {
			if value ?= item?[name] {
				if value is Function {
					result.push(value) if value ?= value*$(item)
				}
				else {
					result.push(value)
				}
			}
		}
		
		return result
	}
}