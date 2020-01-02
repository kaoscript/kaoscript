var Operator = require("@kaoscript/runtime").Operator;
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_cons_3 = function(year, month, day, hours, minutes, seconds, milliseconds) {
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
		that.setUTCMinutes(that.getUTCMinutes() - that.getTimezoneOffset());
		return that;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return new Date();
		}
		else if(arguments.length === 1) {
			return new Date(...arguments);
		}
		else if(arguments.length >= 2 && arguments.length <= 7) {
			return __ks_Date.__ks_cons_3(...arguments);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	const d1 = __ks_Date.new();
	const d2 = __ks_Date.new(d1);
	const d3 = __ks_Date.new(2000, 1, 1);
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};