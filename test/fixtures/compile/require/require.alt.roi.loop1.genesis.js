var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Array, __ks_Object) {
	if(!Type.isValue(__ks_Array)) {
		__ks_Array = {};
	}
	if(!Type.isValue(__ks_Object)) {
		__ks_Object = {};
	}
	__ks_Array.__ks_sttc_clone_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isArray(value)) {
			throw new TypeError("'value' is not of type 'Array'");
		}
		return this;
	};
	__ks_Array._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Array.__ks_sttc_clone_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Object.__ks_sttc_clone_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isObject(value)) {
			throw new TypeError("'value' is not of type 'Object'");
		}
		return this;
	};
	__ks_Object._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Object.__ks_sttc_clone_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	function clone() {
		if(arguments.length === 1 && Type.isArray(arguments[0])) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isArray(value)) {
				throw new TypeError("'value' is not of type 'Array'");
			}
			return this;
		}
		else if(arguments.length === 1 && Type.isObject(arguments[0])) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!Type.isObject(value)) {
				throw new TypeError("'value' is not of type 'Object'");
			}
			return this;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0) {
				value = null;
			}
			return value;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	return {
		__ks_Array: __ks_Array,
		__ks_Object: __ks_Object,
		clone: clone
	};
};