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
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(values) {
		foobar(...values);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isNumber);
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};