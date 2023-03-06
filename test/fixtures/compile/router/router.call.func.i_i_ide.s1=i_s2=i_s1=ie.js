const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		quxbaz.__ks_0(x, y, x);
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
	quxbaz.__ks_0 = function(x, y, z) {
		if(z === void 0 || z === null) {
			z = 0;
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2 && args.length <= 3) {
			if(t0(args[0]) && t0(args[1]) && Helper.isVarargs(args, 0, 1, t1, pts = [2], 0) && te(pts, 1)) {
				return quxbaz.__ks_0.call(that, args[0], args[1], Helper.getVararg(args, 2, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};