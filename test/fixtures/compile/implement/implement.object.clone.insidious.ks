#![libstd(off)]

extern sealed class Object

impl Object {
	static clone(dict) {
		if dict.constructor.clone is Function && dict.constructor.clone != this {
			return dict.constructor.clone(dict)
		}
		if dict.constructor.prototype.clone is Function {
			return dict.clone()
		}

		var dyn clone = {}

		for var value, key of dict {
			if value is array {
				clone[key] = value.clone()
			}
			else if value is dict {
				clone[key] = Object.clone(value)
			}
			else {
				clone[key] = value
			}
		}

		return clone
	}
}