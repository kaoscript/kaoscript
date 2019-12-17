require("kaoscript/register");
var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function(Date, __ks_Date) {
	if(!Type.isValue(Date)) {
		var {Date, __ks_Date} = require("./require.alt.roi.loop3.genesis.ks")();
	}
	__ks_Date.__ks_cons_1 = function(year, month, day, hours, minutes, seconds, milliseconds) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(year === void 0 || year === null) {
			throw new TypeError("'year' is not nullable");
		}
		else if(!(Type.isNumber(year) || Type.isString(year))) {
			throw new TypeError("'year' is not of type 'NS'");
		}
		if(month === void 0 || month === null) {
			throw new TypeError("'month' is not nullable");
		}
		else if(!(Type.isNumber(month) || Type.isString(month))) {
			throw new TypeError("'month' is not of type 'NS'");
		}
		if(day === void 0 || day === null) {
			day = 1;
		}
		else if(!(Type.isNumber(day) || Type.isString(day))) {
			throw new TypeError("'day' is not of type 'NS'");
		}
		if(hours === void 0 || hours === null) {
			hours = 0;
		}
		else if(!(Type.isNumber(hours) || Type.isString(hours))) {
			throw new TypeError("'hours' is not of type 'NS'");
		}
		if(minutes === void 0 || minutes === null) {
			minutes = 0;
		}
		else if(!(Type.isNumber(minutes) || Type.isString(minutes))) {
			throw new TypeError("'minutes' is not of type 'NS'");
		}
		if(seconds === void 0 || seconds === null) {
			seconds = 0;
		}
		else if(!(Type.isNumber(seconds) || Type.isString(seconds))) {
			throw new TypeError("'seconds' is not of type 'NS'");
		}
		if(milliseconds === void 0 || milliseconds === null) {
			milliseconds = 0;
		}
		else if(!(Type.isNumber(milliseconds) || Type.isString(milliseconds))) {
			throw new TypeError("'milliseconds' is not of type 'NS'");
		}
		var that = new Date(year, Operator.subtraction(month, 1), day, hours, minutes, seconds, milliseconds);
		that.setUTCMinutes(that.getUTCMinutes() - that.getTimezoneOffset());
		return that;
	};
	__ks_Date.__ks_func_fromAugment_0 = function() {
	};
	__ks_Date.new = function() {
		if(arguments.length >= 2 && arguments.length <= 7) {
			return __ks_Date.__ks_cons_1(...arguments);
		}
		else if(arguments.length === 0) {
			return new Date();
		}
		else {
			return new Date(...arguments);
		}
	};
	__ks_Date._im_fromAugment = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_fromAugment_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const d = __ks_Date.new(2000, 1, 20, 3, 45, 6, 789);
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};