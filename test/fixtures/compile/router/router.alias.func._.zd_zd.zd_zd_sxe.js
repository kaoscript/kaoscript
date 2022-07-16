const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return 0;
	};
	foobar.__ks_1 = function(x, y) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		return 1;
	};
	foobar.__ks_2 = function(x, y, z) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		const t1 = Type.isRegExp;
		const t2 = value => Type.isString(value) || Type.isRegExp(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		if(args.length >= 1 && args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0)) {
				if(Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return foobar.__ks_2.call(that, Helper.getVararg(args, 0, pts[1]), void 0, Helper.getVararg(args, pts[1], pts[2]));
				}
				if(Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
					return foobar.__ks_1.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t2(args[2])) {
				return foobar.__ks_2.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};