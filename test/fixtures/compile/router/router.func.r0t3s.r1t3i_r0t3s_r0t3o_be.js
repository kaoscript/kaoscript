const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(values, args, dicts, flag) {
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = Type.isDictionary;
		const t3 = Type.isBoolean;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(args.length >= 2 && args.length <= 3) {
			if(Helper.isVarargs(args, 1, 2, t1, pts = [0], 0)) {
				if(Helper.isVarargs(args, 0, 1, t0, pts, 1) && Helper.isVarargs(args, 0, 1, t2, pts, 2) && Helper.isVarargs(args, 1, 1, t3, pts, 3) && te(pts, 4)) {
					return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]), Helper.getVarargs(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
				}
				throw Helper.badArgs();
			}
			if(Helper.isVarargs(args, 2, 3, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(args.length >= 4 && args.length <= 10) {
			if(Helper.isVarargs(args, 1, 3, t1, pts = [0], 0) && Helper.isVarargs(args, 0, 3, t0, pts, 1) && Helper.isVarargs(args, 0, 3, t2, pts, 2) && Helper.isVarargs(args, 1, 1, t3, pts, 3) && te(pts, 4)) {
				return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]), Helper.getVarargs(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
			}
		}
		throw Helper.badArgs();
	};
};