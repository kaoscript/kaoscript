const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_append_0 = function(args) {
		for(let i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
			this.push(...args[i]);
		}
		return this;
	};
	__ks_Array._im_append = function(that, ...args) {
		return __ks_Array.__ks_func_append_rt(that, args);
	};
	__ks_Array.__ks_func_append_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_func_append_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};