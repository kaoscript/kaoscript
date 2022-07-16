const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args, x) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		return 0;
	};
	foobar.__ks_1 = function(value) {
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
		const t1 = Type.isString;
		const t2 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_0.call(that, [args[0]], void 0);
			}
			if(t2(args[0])) {
				return foobar.__ks_0.call(that, [], args[0]);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 0, args.length, t1, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && te(pts, 2)) {
			return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
		}
		throw Helper.badArgs();
	};
};