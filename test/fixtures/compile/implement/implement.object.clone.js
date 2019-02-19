var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_clone_0 = function(object) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
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
		let clone = {};
		for(let key in object) {
			let value = object[key];
			if(Type.isArray(value)) {
				clone[key] = value.clone();
			}
			else if(Type.isObject(value)) {
				clone[key] = __ks_Object._cm_clone(value);
			}
			else {
				clone[key] = value;
			}
		}
		return clone;
	};
	__ks_Object._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Object.__ks_sttc_clone_0.apply(null, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
};