const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, items, y, __ks_cb) {
		if(y === void 0 || y === null) {
			y = 42;
		}
		__ks_cb();
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isFunction;
		const t2 = () => true;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foo.__ks_0.call(that, args[0], [], void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 3, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t2, pts, 1) && Helper.isVarargs(args, 1, 1, t1, pts, 2) && te(pts, 3)) {
				return foo.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		throw Helper.badArgs();
	};
};