const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(u = null, v, x = null, y, z = null) {
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.any;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2 && args.length <= 3) {
			if(Helper.isVarargs(args, 0, args.length - 2, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && Helper.isVarargs(args, 1, 1, t1, pts, 2) && te(pts, 3)) {
				return foobar.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), void 0, Helper.getVararg(args, pts[2], pts[3]), void 0);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 4 && args.length <= 5) {
			if(t1(args[1]) && t1(args[3])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4]);
			}
		}
		throw Helper.badArgs();
	};
};