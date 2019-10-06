var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_clone_0 = function(object) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(object === void 0 || object === null) {
			throw new TypeError("'object' is not nullable");
		}
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
				clone[key] = __ks_Dictionary._cm_clone(value);
			}
			else {
				clone[key] = value;
			}
		}
		return clone;
	};
	__ks_Dictionary._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Dictionary.__ks_sttc_clone_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};