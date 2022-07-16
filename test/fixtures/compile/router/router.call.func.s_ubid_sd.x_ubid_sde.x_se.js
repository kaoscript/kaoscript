const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c) {
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(c === void 0 || c === null) {
			c = "";
		}
	};
	foobar.__ks_1 = function(a, b, c) {
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(c === void 0 || c === null) {
			c = "";
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = value => Type.isBoolean(value) || Type.isNumber(value) || Type.isNull(value);
		const t2 = value => Type.isString(value) || Type.isNull(value);
		const t3 = Type.isRegExp;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 3) {
			if(t0(args[0])) {
				if(Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
					return foobar.__ks_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
				throw Helper.badArgs();
			}
			if(t3(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
				return foobar.__ks_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_1(/\s+/, void 0, "hello");
};