var {initFlag, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_init_1 = function(that) {
		that._culture = "und";
	};
	__ks_Date.__ks_get_culture = function(that) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		return that._culture;
	};
	__ks_Date.__ks_set_culture = function(that, value) {
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._culture = value;
	};
	__ks_Date.__ks_func_culture_0 = function() {
		return __ks_Date.__ks_get_culture(this);
	};
	__ks_Date.__ks_func_culture_1 = function(culture) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(culture === void 0 || culture === null) {
			throw new TypeError("'culture' is not nullable");
		}
		else if(!Type.isString(culture)) {
			throw new TypeError("'culture' is not of type 'String'");
		}
		__ks_Date.__ks_set_culture(this, culture);
		return this;
	};
	__ks_Date.__ks_func_timezone_0 = function() {
		return this._timezone;
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
		this._timezone = timezone;
		return this;
	};
	__ks_Date.__ks_init = function(that) {
		__ks_Date.__ks_init_1(that);
		that[initFlag] = true;
	};
	__ks_Date._im_culture = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_culture_0.apply(that);
		}
		else if(args.length === 1) {
			return __ks_Date.__ks_func_culture_1.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
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
};