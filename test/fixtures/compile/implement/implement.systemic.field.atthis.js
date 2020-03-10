var {initFlag, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_init_0 = function(that) {
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
	__ks_Date.__ks_cons_4 = function(year, month) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(year === void 0 || year === null) {
			throw new TypeError("'year' is not nullable");
		}
		if(month === void 0 || month === null) {
			throw new TypeError("'month' is not nullable");
		}
		let __ks_i = 1;
		let __ks__;
		let day = arguments.length > 3 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
		let hours = arguments.length > 4 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
		let minutes = arguments.length > 5 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
		let seconds = arguments.length > 6 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
		let milliseconds = arguments.length > 7 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
		let timezone = arguments[++__ks_i];
		if(timezone === void 0 || timezone === null) {
			throw new TypeError("'timezone' is not nullable");
		}
		else if(!Type.isString(timezone)) {
			throw new TypeError("'timezone' is not of type 'String'");
		}
		var that = __ks_Date.new(year, month, day, hours, minutes, seconds, milliseconds);
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
		that._timezone = timezone;
		return that;
	};
	__ks_Date.__ks_init = function(that) {
		__ks_Date.__ks_init_0(that);
		that[initFlag] = true;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return new Date();
		}
		else if(arguments.length === 1) {
			return new Date(...arguments);
		}
		else if(arguments.length === 2) {
			return new Date(...arguments);
		}
		else if(arguments.length === 3) {
			if(Type.isString(arguments[2])) {
				return __ks_Date.__ks_cons_4(...arguments);
			}
			else {
				return new Date(...arguments);
			}
		}
		else if(arguments.length === 4) {
			if(Type.isString(arguments[3])) {
				return __ks_Date.__ks_cons_4(...arguments);
			}
			else {
				return new Date(...arguments);
			}
		}
		else if(arguments.length === 5) {
			if(Type.isString(arguments[4])) {
				return __ks_Date.__ks_cons_4(...arguments);
			}
			else {
				return new Date(...arguments);
			}
		}
		else if(arguments.length === 6) {
			if(Type.isString(arguments[5])) {
				return __ks_Date.__ks_cons_4(...arguments);
			}
			else {
				return new Date(...arguments);
			}
		}
		else if(arguments.length === 7) {
			if(Type.isString(arguments[6])) {
				return __ks_Date.__ks_cons_4(...arguments);
			}
			else {
				return new Date(...arguments);
			}
		}
		else if(arguments.length === 8) {
			return __ks_Date.__ks_cons_4(...arguments);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	const d = __ks_Date.new(2015, 6, 15, 9, 3, 1, 550, "Europe/Paris");
};