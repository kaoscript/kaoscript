var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_map_0 = function(dict, iterator) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(dict === void 0 || dict === null) {
			throw new TypeError("'dict' is not nullable");
		}
		else if(!Type.isDictionary(dict)) {
			throw new TypeError("'dict' is not of type 'Dictionary'");
		}
		if(iterator === void 0 || iterator === null) {
			throw new TypeError("'iterator' is not nullable");
		}
		else if(!Type.isFunction(iterator)) {
			throw new TypeError("'iterator' is not of type 'Function'");
		}
		let results = [];
		for(let index in dict) {
			let item = dict[index];
			results.push(iterator(item, index));
		}
		return results;
	};
	__ks_Dictionary.__ks_sttc_map_1 = function(dict, iterator, condition) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(dict === void 0 || dict === null) {
			throw new TypeError("'dict' is not nullable");
		}
		else if(!Type.isDictionary(dict)) {
			throw new TypeError("'dict' is not of type 'Dictionary'");
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
		for(let index in dict) {
			let item = dict[index];
			if(condition(item, index) === true) {
				results.push(iterator(item, index));
			}
		}
		return results;
	};
	__ks_Dictionary._cm_map = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 2) {
			return __ks_Dictionary.__ks_sttc_map_0.apply(null, args);
		}
		else if(args.length === 3) {
			return __ks_Dictionary.__ks_sttc_map_1.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Dictionary: __ks_Dictionary
	};
};