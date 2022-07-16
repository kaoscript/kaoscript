const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(x, value, y, z) {
		if(value === void 0) {
			value = null;
		}
		return 1;
	};
	foobar.__ks_2 = function(x, value, y, z) {
		if(value === void 0) {
			value = null;
		}
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		const t2 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 4) {
			if(t0(args[0])) {
				if(t0(args[2])) {
					if(t0(args[3])) {
						return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3]);
					}
					if(t1(args[3])) {
						return foobar.__ks_2.call(that, args[0], args[1], args[2], args[3]);
					}
				}
			}
			if(t2(args[0]) && t2(args[1]) && t2(args[2]) && t2(args[3])) {
				return foobar.__ks_0.call(that, [args[0], args[1], args[2], args[3]]);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 0, args.length, t2, pts = [0], 0) && te(pts, 1)) {
			return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};