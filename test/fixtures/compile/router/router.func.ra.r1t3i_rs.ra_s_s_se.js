const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(values, args) {
		return 1;
	};
	foobar.__ks_2 = function(value, x, y, z) {
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that, []);
		}
		if(args.length >= 1 && args.length <= 2) {
			if(Helper.isVarargs(args, 1, 2, t0, pts = [0], 0)) {
				if(Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
					return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
				}
			}
			if(Helper.isVarargs(args, 1, 2, t2, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 1, 3, t0, pts = [0], 0)) {
			if(Helper.isVarargs(args, 0, args.length - 1, t1, pts, 1) && te(pts, 2)) {
				return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
			}
		}
		if(Helper.isVarargs(args, 0, args.length - 3, t2, pts = [0], 0)) {
			if(Helper.isVarargs(args, 1, 1, t1, pts, 1)) {
				if(Helper.isVarargs(args, 1, 1, t1, pts, 2) && Helper.isVarargs(args, 1, 1, t1, pts, 3) && te(pts, 4)) {
					return foobar.__ks_2.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
				}
			}
			if(Helper.isVarargs(args, 3, 3, t2, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[2]));
			}
			throw Helper.badArgs();
		}
		throw Helper.badArgs();
	};
};