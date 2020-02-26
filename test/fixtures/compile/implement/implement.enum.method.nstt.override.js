var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Weekday = Helper.enum(Number, {
		MONDAY: 0,
		TUESDAY: 1,
		WEDNESDAY: 2,
		THURSDAY: 3,
		FRIDAY: 4,
		SATURDAY: 5,
		SUNDAY: 6
	});
	Weekday.__ks_func_isWeekend = function(that) {
		return that.value === Weekday.SATURDAY || that.value === Weekday.SUNDAY;
	};
	Weekday.__ks_func_isWeekend = function(that) {
		return that.value === Weekday.SATURDAY || that.value === Weekday.SUNDAY || that.value === Weekday.FRIDAY;
	};
	function foobar(day) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(day === void 0 || day === null) {
			throw new TypeError("'day' is not nullable");
		}
		else if(!Type.isEnumInstance(day, Weekday)) {
			throw new TypeError("'day' is not of type 'Weekday'");
		}
		if(Weekday.__ks_func_isWeekend(day)) {
		}
	}
	return {
		Weekday: Weekday
	};
};