var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_func_setDate_1 = function(value, flag) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		else if(!Type.isNumber(value)) {
			throw new TypeError("'value' is not of type 'Number'");
		}
		if(flag === void 0 || flag === null) {
			flag = true;
		}
		else if(!Type.isBoolean(flag)) {
			throw new TypeError("'flag' is not of type 'Boolean'");
		}
		this.setDate(value);
		return this;
	};
	__ks_Date._im_setDate = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 1 && args.length <= 2) {
			return __ks_Date.__ks_func_setDate_1.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	function foobar(d) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		else if(!Type.is(d, Date)) {
			throw new TypeError("'d' is not of type 'Date'");
		}
	}
	const d = new Date();
	foobar(__ks_Date._im_setDate(d, 1));
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};