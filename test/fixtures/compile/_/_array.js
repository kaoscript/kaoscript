var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_sttc_map_0 = function(array, iterator) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(array === void 0 || array === null) {
			throw new TypeError("'array' is not nullable");
		}
		else if(!Type.isArray(array)) {
			throw new TypeError("'array' is not of type 'Array'");
		}
		if(iterator === void 0 || iterator === null) {
			throw new TypeError("'iterator' is not nullable");
		}
		else if(!Type.isFunction(iterator)) {
			throw new TypeError("'iterator' is not of type 'Function'");
		}
		let results = [];
		for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
			item = array[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Array.__ks_sttc_map_1 = function(array, iterator, condition) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(array === void 0 || array === null) {
			throw new TypeError("'array' is not nullable");
		}
		else if(!Type.isArray(array)) {
			throw new TypeError("'array' is not of type 'Array'");
		}
		if(iterator === void 0 || iterator === null) {
			throw new TypeError("'iterator' is not nullable");
		}
		else if(!Type.isFunction(iterator)) {
			throw new TypeError("'iterator' is not of type 'Function'");
		}
		if(condition === void 0 || condition === null) {
			throw new TypeError("'condition' is not nullable");
		}
		else if(!Type.isFunction(condition)) {
			throw new TypeError("'condition' is not of type 'Function'");
		}
		let results = [];
		for(let index = 0, __ks_0 = array.length, item; index < __ks_0; ++index) {
			item = array[index];
			if(condition(item, index) === true) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		else if(!Type.isNumber(index)) {
			throw new TypeError("'index' is not of type 'Number'");
		}
		return (this.length !== 0) ? this[this.length - index] : null;
	};
	__ks_Array._cm_map = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 2) {
			return __ks_Array.__ks_sttc_map_0.apply(null, args);
		}
		else if(args.length === 3) {
			return __ks_Array.__ks_sttc_map_1.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Array._im_last = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Array.__ks_func_last_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Array: __ks_Array
	};
};