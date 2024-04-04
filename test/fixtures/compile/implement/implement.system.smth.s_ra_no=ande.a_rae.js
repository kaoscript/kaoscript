const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Function = {};
	__ks_Function.__ks_sttc_curry_0 = function(fn, args, bind = null) {
	};
	__ks_Function._sm_curry = function(kws, ...args) {
		const t0 = Type.any;
		const t1 = Type.isString;
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(t0(kws.bind)) {
			if(args.length >= 1) {
				if(t1(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t2, pts = [1], 0) && te(pts, 1)) {
					return __ks_Function.__ks_sttc_curry_0(args[0], Helper.getVarargs(args, 1, pts[1]), kws.bind);
				}
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(fn, args) {
		__ks_Function._sm_curry({}, fn, ...args);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t0, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};