const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(name, args) {
		return 0;
	};
	foobar.__ks_1 = function(name, args, flag) {
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = value => Type.isNumber(value) || Type.isString(value);
		const t2 = Type.isBoolean;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0], []);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 2) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t1, pts = [1], 0)) {
				if(Helper.isVarargs(args, 1, 1, t2, pts, 1) && te(pts, 2)) {
					return foobar.__ks_1.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
				if(Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[2]));
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
};