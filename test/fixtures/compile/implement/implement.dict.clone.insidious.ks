extern sealed class Dictionary

impl Dictionary {
	static clone(dict) {
		if dict.constructor.clone is Function && dict.constructor.clone != this {
			return dict.constructor.clone(dict)
		}
		if dict.constructor.prototype.clone is Function {
			return dict.clone()
		}

		let clone = {}

		for value, key of dict {
			if value is array {
				clone[key] = value.clone()
			}
			else if value is dict {
				clone[key] = Dictionary.clone(value)
			}
			else {
				clone[key] = value
			}
		}

		return clone
	}
}