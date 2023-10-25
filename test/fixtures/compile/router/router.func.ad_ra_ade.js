const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, items, y) {
		if(x === void 0 || x === null) {
			x = 24;
		}
		if(y === void 0 || y === null) {
			y = 42;
		}
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.any;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, args.length - 2, t1, pts, 1) && Helper.isVarargs(args, 0, 1, t0, pts, 2) && te(pts, 3)) {
			return foobar.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
		}
		throw Helper.badArgs();
	};
};