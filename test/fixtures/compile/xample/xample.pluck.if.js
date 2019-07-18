var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_pluck_0 = function(name) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		let result = [];
		let value;
		for(let __ks_0 = 0, __ks_1 = this.length, item; __ks_0 < __ks_1; ++__ks_0) {
			item = this[__ks_0];
			if(Type.isValue(item) && Type.isValue(item[name]) ? (value = item[name], true) : false) {
				if(Type.isFunction(value)) {
					let __ks_2;
					if(Type.isValue(__ks_2 = value.call(item)) ? (value = __ks_2, true) : false) {
						result.push(value);
					}
				}
				else {
					result.push(value);
				}
			}
		}
		return result;
	};
	__ks_Array._im_pluck = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Array.__ks_func_pluck_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};