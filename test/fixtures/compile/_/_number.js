var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Number = {};
	var __ks_Math = {};
	__ks_Number.__ks_func_limit_0 = function(min, max) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(min === void 0 || min === null) {
			throw new TypeError("'min' is not nullable");
		}
		else if(!Type.isNumber(min)) {
			throw new TypeError("'min' is not of type 'Number'");
		}
		if(max === void 0 || max === null) {
			throw new TypeError("'max' is not nullable");
		}
		else if(!Type.isNumber(max)) {
			throw new TypeError("'max' is not of type 'Number'");
		}
		return (isNaN(this) === true) ? min : Math.min(max, Math.max(min, this));
	};
	__ks_Number.__ks_func_mod_0 = function(max) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(max === void 0 || max === null) {
			throw new TypeError("'max' is not nullable");
		}
		else if(!Type.isNumber(max)) {
			throw new TypeError("'max' is not of type 'Number'");
		}
		if(isNaN(this) === true) {
			return 0;
		}
		else {
			let n = this % max;
			if(n < 0) {
				return n + max;
			}
			else {
				return n;
			}
		}
	};
	__ks_Number.__ks_func_round_0 = function(precision) {
		if(precision === void 0 || precision === null) {
			precision = 0;
		}
		else if(!Type.isNumber(precision)) {
			throw new TypeError("'precision' is not of type 'Number'");
		}
		precision = Math.pow(10, precision).toFixed(0);
		return Math.round(this * precision) / precision;
	};
	__ks_Number.__ks_func_toFloat_0 = function() {
		return parseFloat(this);
	};
	__ks_Number.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		else if(!Type.isNumber(base)) {
			throw new TypeError("'base' is not of type 'Number'");
		}
		return parseInt(this, base);
	};
	__ks_Number._im_limit = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 2) {
			return __ks_Number.__ks_func_limit_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Number._im_mod = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Number.__ks_func_mod_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Number._im_round = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Number.__ks_func_round_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Number._im_toFloat = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Number.__ks_func_toFloat_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Number._im_toInt = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Number.__ks_func_toInt_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Number: __ks_Number
	};
};