const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_clone_0 = function(object) {
		if(Type.isFunction(object.constructor.clone) && (object.constructor.clone !== this)) {
			return object.constructor.clone(object);
		}
		if(Type.isFunction(object.constructor.prototype.clone)) {
			return object.clone();
		}
		let clone = new OBJ();
		for(const key in object) {
			const value = object[key];
			if(Type.isArray(value)) {
				clone[key] = value.clone();
			}
			else if(Type.isObject(value)) {
				clone[key] = __ks_Object.__ks_sttc_clone_0(value);
			}
			else {
				clone[key] = value;
			}
		}
		return clone;
	};
	__ks_Object._sm_clone = function() {
		const t0 = Type.isValue;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Object.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Object.clone) {
			return Object.clone(...arguments);
		}
		throw Helper.badArgs();
	};
};