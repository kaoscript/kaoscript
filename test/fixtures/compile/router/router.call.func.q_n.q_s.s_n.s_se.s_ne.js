var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Weekday = Helper.struct(function(index, name) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(index === void 0 || index === null) {
			throw new TypeError("'index' is not nullable");
		}
		else if(!Type.isNumber(index)) {
			throw new TypeError("'index' is not of type 'Number'");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		const _ = new Dictionary();
		_.index = index;
		_.name = name;
		return _;
	});
	function foobar() {
		if(arguments.length === 2 && Type.isStructInstance(arguments[0], Weekday) && Type.isNumber(arguments[1])) {
			let __ks_i = -1;
			let day = arguments[++__ks_i];
			if(day === void 0 || day === null) {
				throw new TypeError("'day' is not nullable");
			}
			else if(!Type.isStructInstance(day, Weekday)) {
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
		else if(arguments.length === 2 && Type.isStructInstance(arguments[0], Weekday)) {
			let __ks_i = -1;
			let day = arguments[++__ks_i];
			if(day === void 0 || day === null) {
				throw new TypeError("'day' is not nullable");
			}
			else if(!Type.isStructInstance(day, Weekday)) {
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