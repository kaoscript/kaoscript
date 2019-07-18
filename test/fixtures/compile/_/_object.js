module.exports = function(Helper, Type) {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_map_0 = function(object, iterator) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(object === void 0 || object === null) {
			throw new TypeError("'object' is not nullable");
		}
		else if(!Type.isObject(object)) {
			throw new TypeError("'object' is not of type 'Object'");
		}
		if(iterator === void 0 || iterator === null) {
			throw new TypeError("'iterator' is not nullable");
		}
		else if(!Type.isFunction(iterator)) {
			throw new TypeError("'iterator' is not of type 'Function'");
		}
		let results = [];
		for(let index in object) {
			let item = object[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Object.__ks_sttc_map_1 = function(object, iterator, condition) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(object === void 0 || object === null) {
			throw new TypeError("'object' is not nullable");
		}
		else if(!Type.isObject(object)) {
			throw new TypeError("'object' is not of type 'Object'");
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
		for(let index in object) {
			let item = object[index];
			if(condition(item, index)) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Object._cm_map = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 2) {
			return __ks_Object.__ks_sttc_map_0.apply(null, args);
		}
		else if(args.length === 3) {
			return __ks_Object.__ks_sttc_map_1.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		Object: Object,
		__ks_Object: __ks_Object
	};
};