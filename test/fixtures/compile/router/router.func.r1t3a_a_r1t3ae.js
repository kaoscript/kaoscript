const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items, x, values) {
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 3 && args.length <= 4) {
			if(Helper.isVarargs(args, 1, args.length - 2, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && Helper.isVarargs(args, 1, 1, t0, pts, 2) && te(pts, 3)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVarargs(args, pts[2], pts[3]));
			}
			throw Helper.badArgs();
		}
		if(args.length >= 5 && args.length <= 7) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && Helper.isVarargs(args, 1, 3, t0, pts = [4], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, [args[0], args[1], args[2]], args[3], Helper.getVarargs(args, 4, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};