const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b) {
		if(a === void 0 || a === null) {
			a = "";
		}
		if(b === void 0 || b === null) {
			b = "";
		}
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
};