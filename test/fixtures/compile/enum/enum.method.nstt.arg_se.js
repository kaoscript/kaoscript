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
	Weekday.__ks_func_isSameAs = function(that, day) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(day === void 0 || day === null) {
			throw new TypeError("'day' is not nullable");
		}
		else if(!Type.isString(day)) {
			throw new TypeError("'day' is not of type 'String'");
		}
		let __ks_0 = this.value;
		if(__ks_0 === Weekday.MONDAY) {
			return day === "monday";
		}
		return false;
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
		if(Weekday.__ks_func_isSameAs(day, "tuesday")) {
		}
	}
	return {
		Weekday: Weekday
	};
};