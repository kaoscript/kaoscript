const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Array = {};
	__ks_Array._im_push = function(that, gens, ...args) {
		return __ks_Array.__ks_func_push_rt(that, gens || {}, args);
	};
	__ks_Array.__ks_func_push_rt = function(that, gens, args) {
		const t0 = gens.T || Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return that.push.call(that, ...Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array
	};
};