import {
	*				from ./polyfill.ks
}

impl Object {
	static clone(object) {
		if object.constructor.clone is Function && object.constructor.clone != this {
			return object.constructor.clone(object)
		}
		if object.constructor.prototype.clone is Function {
			return object.clone()
		}
		
		let clone = {}
		
		for key, value of object {
			if value is array {
				clone[key] = value.clone()
			}
			else if value is object {
				clone[key] = Object.clone(value)
			}
			else {
				clone[key] = value
			}
		}
		
		return clone
	}
}