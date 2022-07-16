const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x = null, items, __ks_cb) {
		__ks_cb();
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, void 0, [], args[0]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 2) {
			if(t1(args[0])) {
				if(Helper.isVarargs(args, 0, args.length - 2, t2, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
					return foo.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
				throw Helper.badArgs();
			}
			if(Helper.isVarargs(args, 1, args.length - 1, t2, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
				return foo.__ks_0.call(that, void 0, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
};