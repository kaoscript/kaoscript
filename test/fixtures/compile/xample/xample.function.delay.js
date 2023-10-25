const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Function = {};
	__ks_Function.__ks_func_delay_0 = function(time, args, bind = null) {
		return setTimeout(() => this.call(bind, ...args), time);
	};
	__ks_Function._im_delay = function(that, kws, ...args) {
		return __ks_Function.__ks_func_delay_rt(that, kws, args);
	};
	__ks_Function.__ks_func_delay_rt = function(that, kws, args) {
		const t0 = Type.any;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(t0(kws.bind)) {
			if(args.length >= 1) {
				if(t1(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
					return __ks_Function.__ks_func_delay_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), kws.bind);
				}
			}
		}
		throw Helper.badArgs();
	};
};