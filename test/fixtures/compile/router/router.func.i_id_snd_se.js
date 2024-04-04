const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, c, b = null, e) {
		if(c === void 0 || c === null) {
			c = 0;
		}
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		const t2 = value => Type.isNumber(value) || Type.isNull(value);
		const t3 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], void 0, void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3 && args.length <= 4) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t2, pts = [1], 0) && Helper.isVarargs(args, 0, Helper.getVarargMax(args, 1, pts, 0, 1), t3, pts, 1) && Helper.isVarargs(args, 1, 1, t1, pts, 2) && te(pts, 3)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		throw Helper.badArgs();
	};
};