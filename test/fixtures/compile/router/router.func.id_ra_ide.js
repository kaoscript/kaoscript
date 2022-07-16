const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, items, y) {
		if(x === void 0 || x === null) {
			x = 24;
		}
		if(y === void 0 || y === null) {
			y = 42;
		}
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that, void 0, []);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0], [], void 0);
			}
			if(t1(args[0])) {
				return foobar.__ks_0.call(that, void 0, [args[0]], void 0);
			}
			throw Helper.badArgs();
		}
		if(t0(args[0])) {
			if(Helper.isVarargs(args, 0, args.length - 2, t1, pts = [1], 0)) {
				if(Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
					return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
				if(Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return foobar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[2]), void 0);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 1, args.length - 1, t1, pts = [0], 0)) {
			if(Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, void 0, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
			if(Helper.isVarargs(args, 1, args.length - 1, t1, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, void 0, Helper.getVarargs(args, 0, pts[2]), void 0);
			}
			throw Helper.badArgs();
		}
		throw Helper.badArgs();
	};
};