var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Number, __ks_Math) {
	if(!Type.isValue(__ks_Number)) {
		__ks_Number = {};
	}
	if(!Type.isValue(__ks_Math)) {
		__ks_Math = {};
	}
	console.log(Math.PI.toString());
	__ks_Number.__ks_func_round_0 = function(precision) {
		if(precision === void 0 || precision === null) {
			precision = 0;
		}
		else if(!Type.isNumber(precision)) {
			throw new TypeError("'precision' is not of type 'Number'");
		}
		precision = Math.pow(10, precision).toFixed(0);
		return Math.round(this * precision) / precision;
	};
	__ks_Number._im_round = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Number.__ks_func_round_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	console.log(__ks_Number._im_round(Math.PI).toString());
	return {
		__ks_Number: __ks_Number,
		__ks_Math: __ks_Math
	};
};