const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Number, __ks_Math) {
	if(!__ks_Number) {
		__ks_Number = {};
	}
	console.log(Math.PI.toString());
	__ks_Number.__ks_func_round_0 = function(precision) {
		if(precision === void 0 || precision === null) {
			precision = 0;
		}
		precision = Helper.assertNumber(Math.pow(10, precision).toFixed(0), 0);
		return Math.round.__ks_0([this * precision]) / precision;
	};
	__ks_Number._im_round = function(that, ...args) {
		return __ks_Number.__ks_func_round_rt(that, args);
	};
	__ks_Number.__ks_func_round_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Number.__ks_func_round_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Number.__ks_func_round_0.call(Math.PI).toString());
	return {
		__ks_Number,
		__ks_Math
	};
};