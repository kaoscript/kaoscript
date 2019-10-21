var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_func_equals_0 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isInstance(value, Date)) {
			throw new TypeError("'value' is not of type 'Date'");
		}
		return this.getTime() === value.getTime();
	};
	__ks_Date.__ks_func_equals_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return false;
	};
	__ks_Date.__ks_func_equals_2 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0) {
			value = null;
		}
		return false;
	};
	__ks_Date._im_equals = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			if(Type.isInstance(args[0], Date)) {
				return __ks_Date.__ks_func_equals_0.apply(that, args);
			}
			else if(Type.isValue(args[0])) {
				return __ks_Date.__ks_func_equals_1.apply(that, args);
			}
			else {
				return __ks_Date.__ks_func_equals_2.apply(that, args);
			}
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};