require("kaoscript/register");
const {Helper, initFlag, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Date, __ks_Math) {
	var __ks_0_valuable = Type.isValue(__ks_Date);
	var __ks_1_valuable = Type.isValue(__ks_Math);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var __ks__ = require("./.implement.system.ctor.clash.typing.ks.fpb9zp.ksb")();
		if(!__ks_0_valuable) {
			__ks_Date = __ks__.__ks_Date;
		}
		if(!__ks_1_valuable) {
			__ks_Math = __ks__.__ks_Math;
		}
	}
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
	__ks_Date.__ks_new_3 = function(...args) {
		return __ks_Date.__ks_cons_3(...args);
	};
	__ks_Date.__ks_cons_3 = function(date) {
		const that = new Date(date);
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._timezone = __ks_Date.__ks_func_timezone_0.call(date);
		return that;
	};
	__ks_Date.__ks_func_timezone_0 = function() {
		return __ks_Date.__ks_get_timezone(this);
	};
	__ks_Date.__ks_func_timezone_1 = function(timezone) {
		__ks_Date.__ks_set_timezone(this, timezone);
		return this;
	};
	__ks_Date.__ks_init = function(that) {
		that._timezone = "Etc/UTC";
		that[initFlag] = true;
	};
	__ks_Date.new = function() {
		const t0 = Type.isNumber;
		const t1 = value => Type.isClassInstance(value, Date);
		if(arguments.length === 0) {
			return new Date();
		}
		if(arguments.length === 1) {
			if(t0(arguments[0])) {
				return new Date(arguments[0]);
			}
			if(t1(arguments[0])) {
				return __ks_Date.__ks_cons_3(arguments[0]);
			}
		}
		throw Helper.badArgs();
	};
	__ks_Date._im_timezone = function(that, ...args) {
		return __ks_Date.__ks_func_timezone_rt(that, args);
	};
	__ks_Date.__ks_func_timezone_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 0) {
			return __ks_Date.__ks_func_timezone_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Date.__ks_func_timezone_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Date
	};
};