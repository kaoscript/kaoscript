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
	function foobar() {
		if(arguments.length === 2 && Type.isEnumInstance(arguments[0], Weekday) && Type.isNumber(arguments[1])) {
			let __ks_i = -1;
			let day = arguments[++__ks_i];
			if(day === void 0 || day === null) {
				throw new TypeError("'day' is not nullable");
			}
			else if(!Type.isEnumInstance(day, Weekday)) {
				throw new TypeError("'day' is not of type 'Weekday'");
			}
			let month = arguments[++__ks_i];
			if(month === void 0 || month === null) {
				throw new TypeError("'month' is not nullable");
			}
			else if(!Type.isNumber(month)) {
				throw new TypeError("'month' is not of type 'Number'");
			}
			return 0;
		}
		else if(arguments.length === 2 && Type.isEnumInstance(arguments[0], Weekday)) {
			let __ks_i = -1;
			let day = arguments[++__ks_i];
			if(day === void 0 || day === null) {
				throw new TypeError("'day' is not nullable");
			}
			else if(!Type.isEnumInstance(day, Weekday)) {
				throw new TypeError("'day' is not of type 'Weekday'");
			}
			let month = arguments[++__ks_i];
			if(month === void 0 || month === null) {
				throw new TypeError("'month' is not nullable");
			}
			else if(!Type.isString(month)) {
				throw new TypeError("'month' is not of type 'String'");
			}
			return 1;
		}
		else if(arguments.length === 2 && Type.isNumber(arguments[1])) {
			let __ks_i = -1;
			let day = arguments[++__ks_i];
			if(day === void 0 || day === null) {
				throw new TypeError("'day' is not nullable");
			}
			else if(!Type.isString(day)) {
				throw new TypeError("'day' is not of type 'String'");
			}
			let month = arguments[++__ks_i];
			if(month === void 0 || month === null) {
				throw new TypeError("'month' is not nullable");
			}
			else if(!Type.isNumber(month)) {
				throw new TypeError("'month' is not of type 'Number'");
			}
			return 2;
		}
		else if(arguments.length === 2) {
			let __ks_i = -1;
			let day = arguments[++__ks_i];
			if(day === void 0 || day === null) {
				throw new TypeError("'day' is not nullable");
			}
			else if(!Type.isString(day)) {
				throw new TypeError("'day' is not of type 'String'");
			}
			let month = arguments[++__ks_i];
			if(month === void 0 || month === null) {
				throw new TypeError("'month' is not nullable");
			}
			else if(!Type.isString(month)) {
				throw new TypeError("'month' is not of type 'String'");
			}
			return 3;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	foobar("", -1);
};