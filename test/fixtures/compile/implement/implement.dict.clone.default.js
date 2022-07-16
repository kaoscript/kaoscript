const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_clone_0 = function(object) {
		if(Type.isFunction(object.constructor.clone) && (object.constructor.clone !== this)) {
			return object.constructor.clone(object);
		}
		if(Type.isFunction(object.constructor.prototype.clone)) {
			return object.clone();
		}
		let clone = new Dictionary();
		for(let key in object) {
			let value = object[key];
			if(Type.isArray(value)) {
				clone[key] = value.clone();
			}
			else if(Type.isDictionary(value)) {
				clone[key] = __ks_Dictionary.__ks_sttc_clone_0(value);
			}
			else {
				clone[key] = value;
			}
		}
		return clone;
	};
	__ks_Dictionary._sm_clone = function() {
		const t0 = Type.isValue;
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return __ks_Dictionary.__ks_sttc_clone_0(arguments[0]);
			}
		}
		if(Dictionary.clone) {
			return Dictionary.clone(...arguments);
		}
		throw Helper.badArgs();
	};
};