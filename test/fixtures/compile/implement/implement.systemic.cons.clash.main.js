require("kaoscript/register");
var {initFlag, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date, __ks_Math) {
	var __ks_0_valuable = Type.isValue(__ks_Date);
	var __ks_1_valuable = Type.isValue(__ks_Math);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var __ks__ = require("./implement.systemic.cons.clash.typing.ks")();
		if(!__ks_0_valuable) {
			__ks_Date = __ks__.__ks_Date;
		}
		if(!__ks_1_valuable) {
			__ks_Math = __ks__.__ks_Math;
		}
	}
	__ks_Date.__ks_init_1 = function(that) {
		that._timezone = "Etc/UTC";
	};
	__ks_Date.__ks_get_timezone = function(that) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		return that._timezone;
	};
	__ks_Date.__ks_set_timezone = function(that, value) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._timezone = value;
	};
	__ks_Date.__ks_cons_3 = function(date) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(date === void 0 || date === null) {
			throw new TypeError("'date' is not nullable");
		}
		else if(!Type.isClassInstance(date, Date)) {
			throw new TypeError("'date' is not of type 'Date'");
		}
		var that = new Date(date);
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._timezone = __ks_Date._im_timezone(date);
		return that;
	};
	__ks_Date.__ks_func_timezone_0 = function() {
		return __ks_Date.__ks_get_timezone(this);
	};
	__ks_Date.__ks_func_timezone_1 = function(timezone) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(timezone === void 0 || timezone === null) {
			throw new TypeError("'timezone' is not nullable");
		}
		else if(!Type.isString(timezone)) {
			throw new TypeError("'timezone' is not of type 'String'");
		}
		__ks_Date.__ks_set_timezone(this, timezone);
		return this;
	};
	__ks_Date.__ks_init = function(that) {
		__ks_Date.__ks_init_1(that);
		that[initFlag] = true;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return new Date();
		}
		else if(arguments.length === 1) {
			if(Type.isNumber(arguments[0])) {
				return new Date(...arguments);
			}
			else {
				return __ks_Date.__ks_cons_3(...arguments);
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	__ks_Date._im_timezone = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_timezone_0.apply(that);
		}
		else if(args.length === 1) {
			return __ks_Date.__ks_func_timezone_1.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Date: __ks_Date
	};
};