var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Number, typeof __ks_Number === "undefined" ? {} : __ks_Number);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Number, __ks_Number] = __ks_require(__ks_0, __ks___ks_0);
	var __ks_Math = {};
	console.log(Math.PI.toString());
	__ks_Number.__ks_func_round_0 = function(precision) {
		if(precision === void 0 || precision === null) {
			precision = 0;
		}
		precision = Math.pow(10, precision).toFixed(0);
		return Math.round(this * precision) / precision;
	};
	__ks_Number._im_round = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Number.__ks_func_round_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	console.log(__ks_Number._im_round(Math.PI).toString());
	return {
		Number: Number,
		__ks_Number: __ks_Number,
		Math: Math,
		__ks_Math: __ks_Math
	};
};