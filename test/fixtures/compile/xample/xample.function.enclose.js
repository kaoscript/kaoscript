const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = {};
	__ks_Function.__ks_func_enclose_0 = function(enclosure) {
		let f = this;
		return Helper.function((args) => {
			return enclosure(f, ...args);
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return fn.call(null, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		});
	};
	__ks_Function._im_enclose = function(that, ...args) {
		return __ks_Function.__ks_func_enclose_rt(that, args);
	};
	__ks_Function.__ks_func_enclose_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_Function.__ks_func_enclose_0.call(that, args[0]);
			}
		}
		if(that.enclose) {
			return that.enclose(...args);
		}
		throw Helper.badArgs();
	};
};