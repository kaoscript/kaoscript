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
	Weekday.__ks_func_foobar = function(that) {
		if(arguments.length < 4) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		let __ks_i = 0;
		let values = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 3);
		let x = arguments[__ks_i];
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		let y = arguments[++__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		let z = arguments[++__ks_i];
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
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
		if(Weekday.__ks_func_foobar(day, 1, 2, 3)) {
		}
	}
	return {
		Weekday: Weekday
	};
};