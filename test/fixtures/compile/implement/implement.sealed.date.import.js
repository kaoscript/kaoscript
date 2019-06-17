require("kaoscript/register");
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		var {Date, __ks_Date} = require("../_/_date.ks")();
		req.push(Date, __ks_Date);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Date, __ks_Date] = __ks_require(__ks_0, __ks___ks_0);
	__ks_Date.__ks_sttc_today_0 = function() {
		return __ks_Date._im_midnight(new Date());
	};
	__ks_Date.__ks_func_midnight_0 = function() {
		this.setHours(0);
		this.setMinutes(0);
		this.setSeconds(0);
		this.setMilliseconds(0);
		return this;
	};
	__ks_Date._cm_today = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 0) {
			return __ks_Date.__ks_sttc_today_0();
		}
		throw new SyntaxError("wrong number of arguments");
	};
	__ks_Date._im_midnight = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Date.__ks_func_midnight_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	console.log(__ks_Date._cm_today());
	console.log(__ks_Date._im_midnight(new Date()));
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};