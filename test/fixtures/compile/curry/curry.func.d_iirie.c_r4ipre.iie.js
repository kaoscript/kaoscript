const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, values) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2) {
			if(t0(args[0]) && t0(args[1]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [2], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], args[1], Helper.getVarargs(args, 2, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	const values = [1, 2, 3, 4];
	const quxbaz = Helper.curry((fn, ...args) => {
		const t0 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return fn[0](Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	}, (__ks_0) => foobar.__ks_0(values[0], values[1], values.slice(2).concat(__ks_0)));
	quxbaz.__ks_0([5, 6]);
};