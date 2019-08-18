extern sealed class Object

impl Object {
	static clone(object) {
		if object.constructor.clone is Function && object.constructor.clone != this {
			return object.constructor.clone(object)
		}
		if object.constructor.prototype.clone is Function {
			return object.clone()
		}

		let clone = {}

		for value, key of object {
			if value is Array {
				clone[key] = value.clone()
			}
			else if value is Object {
				clone[key] = Object.clone(value)
			}
			else {
				clone[key] = value
			}
		}

		return clone
	}
}