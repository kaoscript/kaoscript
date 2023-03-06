const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, values, z) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	const values = [1, 2, 3, 4, 5];
	foobar.__ks_0(values[0], values.slice(1, 4), values[4]);
};