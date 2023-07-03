extern sealed class Array

impl Array {
	pluck(name) {
		var dyn result = []

		var dyn value
		for var item in this {
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