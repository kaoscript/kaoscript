const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c) {
		if(a === void 0 || a === null) {
			a = "0";
		}
		if(b === void 0 || b === null) {
			b = "0";
		}
		if(c === void 0 || c === null) {
			c = "0";
		}
		return 0;
	};
	foobar.__ks_1 = function(x, y, z, a, b, c) {
		if(y === void 0 || y === null) {
			y = 0;
		}
		if(z === void 0 || z === null) {
			z = 0;
		}
		if(a === void 0 || a === null) {
			a = "0";
		}
		if(b === void 0 || b === null) {
			b = "0";
		}
		if(c === void 0 || c === null) {
			c = "0";
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const t2 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		if(args.length >= 1 && args.length <= 3) {
			if(t0(args[0])) {
				if(Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && Helper.isVarargs(args, 0, 1, t2, pts, 2) && Helper.isVarargs(args, 0, 1, t2, pts, 3) && te(pts, 4)) {
					return foobar.__ks_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]), void 0);
				}
				throw Helper.badArgs();
			}
			if(t2(args[0]) && Helper.isVarargs(args, 0, 1, t2, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		}
		if(args.length >= 4 && args.length <= 6) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && Helper.isVarargs(args, 1, 1, t2, pts, 2) && Helper.isVarargs(args, 0, 1, t2, pts, 3) && Helper.isVarargs(args, 0, 1, t2, pts, 4) && te(pts, 5)) {
				return foobar.__ks_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]), Helper.getVararg(args, pts[4], pts[5]));
			}
		}
		throw Helper.badArgs();
	};
};