const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items, a, b, c, d) {
		if(b === void 0 || b === null) {
			b = 1;
		}
		if(c === void 0 || c === null) {
			c = 2;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = () => true;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, [], args[0], void 0, void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[2])) {
				return foobar.__ks_0.call(that, [], args[0], args[1], void 0, args[2]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 4) {
			if(Helper.isVarargs(args, 0, args.length - 4, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && Helper.isVarargs(args, 1, 1, t1, pts, 2) && Helper.isVarargs(args, 1, 1, t1, pts, 3) && Helper.isVarargs(args, 1, 1, t0, pts, 4) && te(pts, 5)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]), Helper.getVararg(args, pts[4], pts[5]));
			}
		}
		throw Helper.badArgs();
	};
};