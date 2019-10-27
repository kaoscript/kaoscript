var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	var __ks_Date = {};
	__ks_Date.__ks_func_getHours_1 = function() {
		return this.getUTCHours();
	};
	__ks_Date.__ks_func_setHours_1 = function(hours) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(hours === void 0 || hours === null) {
			throw new TypeError("'hours' is not nullable");
		}
		else if(!Type.isNumber(hours)) {
			throw new TypeError("'hours' is not of type 'Number'");
		}
		this.setUTCHours(hours);
		return this;
	};
	__ks_Date._im_getHours = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_getHours_1.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Date._im_setHours = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Date.__ks_func_setHours_1.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const d = new Date();
	expect(__ks_Date._im_setHours(d, 12)).to.equal(d);
	expect(__ks_Date._im_getHours(d)).to.equal(12);
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};