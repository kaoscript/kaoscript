const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items, x, y, z) {
		if(y === void 0 || y === null) {
			y = 1;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isValue;
		const t2 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, [], args[0], void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3) {
			if(Helper.isVarargs(args, 0, args.length - 3, t1, pts = [0], 0)) {
				if(Helper.isVarargs(args, 1, 1, t0, pts, 1)) {
					if(Helper.isVarargs(args, 1, 1, t2, pts, 2) && Helper.isVarargs(args, 1, 1, t0, pts, 3) && te(pts, 4)) {
						return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
					}
				}
				if(Helper.isVarargs(args, 1, 1, t1, pts, 1) && Helper.isVarargs(args, 1, 1, t0, pts, 2) && Helper.isVarargs(args, 1, 1, t0, pts, 3) && te(pts, 4)) {
					return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[2]), Helper.getVararg(args, pts[2], pts[3]), void 0, Helper.getVararg(args, pts[3], pts[4]));
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
};