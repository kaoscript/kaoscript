const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, values) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t0, pts = [1], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x, y, z) {
		if(y === void 0) {
			y = null;
		}
		if(z === void 0) {
			z = null;
		}
		foobar(x, y, z);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};