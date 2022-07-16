const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(args, flag) {
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		const t1 = Type.isBoolean;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that, []);
		}
		if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0)) {
			if(Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
				return foobar.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
			if(Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0([0]);
};