const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array) {
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		return (this.length !== 0) ? this[Operator.subtraction(this.length, index)] : null;
	};
	__ks_Array._im_last = function(that, ...args) {
		return __ks_Array.__ks_func_last_rt(that, args);
	};
	__ks_Array.__ks_func_last_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Array.__ks_func_last_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		if(that.last) {
			return that.last(...args);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};