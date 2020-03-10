var {initFlag, Operator} = require("@kaoscript/runtime");
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
	__ks_Date.__ks_cons_4 = function(year, month, day, hours, minutes, seconds, milliseconds) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(year === void 0 || year === null) {
			throw new TypeError("'year' is not nullable");
		}
		if(month === void 0 || month === null) {
			throw new TypeError("'month' is not nullable");
		}
		if(day === void 0 || day === null) {
			day = 1;
		}
		if(hours === void 0 || hours === null) {
			hours = 0;
		}
		if(minutes === void 0 || minutes === null) {
			minutes = 0;
		}
		if(seconds === void 0 || seconds === null) {
			seconds = 0;
		}
		if(milliseconds === void 0 || milliseconds === null) {
			milliseconds = 0;
		}
		var that = new Date(year, Operator.subtraction(month, 1), day, hours, minutes, seconds, milliseconds);
		if(!that[initFlag]) {
			__ks_Date.__ks_init(that);
		}
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
		else if(arguments.length >= 2 && arguments.length <= 7) {
			return __ks_Date.__ks_cons_4(...arguments);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	const d = __ks_Date.new(2015, 6, 15, 9, 3, 1, 550);
	return {
		__ks_Date: __ks_Date
	};
};