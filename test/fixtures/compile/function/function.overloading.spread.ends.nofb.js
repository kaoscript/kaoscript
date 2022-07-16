const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args, value) {
		console.log("Array");
	};
	foobar.__ks_1 = function(args, value) {
		console.log("String");
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isArray;
		const t2 = Type.isString;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0)) {
				if(Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
				if(Helper.isVarargs(args, 1, 1, t2, pts, 1) && te(pts, 2)) {
					return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
	return {
		foobar
	};
};