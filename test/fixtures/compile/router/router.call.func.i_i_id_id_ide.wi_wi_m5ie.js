const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(foo, bar) {
		quxbaz.__ks_0(foo, bar, void 0, void 0, 0);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x, y, a, b, z) {
		if(a === void 0 || a === null) {
			a = 0;
		}
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(z === void 0 || z === null) {
			z = 0;
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2 && args.length <= 5) {
			if(t0(args[0]) && t0(args[1]) && Helper.isVarargs(args, 0, 1, t1, pts = [2], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && Helper.isVarargs(args, 0, 1, t1, pts, 2) && te(pts, 3)) {
				return quxbaz.__ks_0.call(that, args[0], args[1], Helper.getVararg(args, 2, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		throw Helper.badArgs();
	};
};