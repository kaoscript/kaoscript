extern sealed class Dictionary

impl Dictionary {
	static clone(object) {
		if object.constructor.clone is Function && object.constructor.clone != this {
			return object.constructor.clone(object)
		}
		if object.constructor.prototype.clone is Function {
			return object.clone()
		}

		var dyn clone = {}

		for value, key of object {
			if value is Array {
				clone[key] = value.clone()
			}
			else if value is Dictionary {
				clone[key] = Dictionary.clone(value)
			}
			else {
				clone[key] = value
			}
		}

		return clone
	}
}