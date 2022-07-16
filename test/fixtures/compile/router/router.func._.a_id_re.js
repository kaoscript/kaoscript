const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return 0;
	};
	foobar.__ks_1 = function(x, y, values) {
		if(y === void 0 || y === null) {
			y = 1;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, args.length - 1, t0, pts, 1) && te(pts, 2)) {
			return foobar.__ks_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
		}
		throw Helper.badArgs();
	};
};