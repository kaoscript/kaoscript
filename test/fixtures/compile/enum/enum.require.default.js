var Type = require("@kaoscript/runtime").Type;
module.exports = function(Weekday) {
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
	foobar(Weekday.WEDNESDAY);
	return {
		Weekday: Weekday
	};
};