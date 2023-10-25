const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(x, args, y) {
		if(y === void 0) {
			y = null;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isNumber;
		const t2 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(t1(args[0])) {
			if(Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t2, pts, 1) && te(pts, 2)) {
				return foobar.__ks_1.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		if(Helper.isVarargs(args, 2, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};