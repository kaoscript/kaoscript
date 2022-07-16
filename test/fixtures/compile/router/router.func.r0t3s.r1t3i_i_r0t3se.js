const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_1 = function(values, flag, args) {
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t1(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_1.call(that, [args[0]], args[1], []);
				}
				throw Helper.badArgs();
			}
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, [args[0], args[1]]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t1(args[0])) {
				if(t1(args[1])) {
					if(t1(args[2])) {
						return foobar.__ks_1.call(that, [args[0], args[1]], args[2], []);
					}
					if(t0(args[2])) {
						return foobar.__ks_1.call(that, [args[0]], args[1], [args[2]]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return foobar.__ks_0.call(that, [args[0], args[1], args[2]]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 4 && args.length <= 5) {
			if(t1(args[0]) && t1(args[1])) {
				if(t1(args[2])) {
					if(t1(args[3])) {
						if(Helper.isVarargs(args, 0, 1, t0, pts = [4], 0) && te(pts, 1)) {
							return foobar.__ks_1.call(that, [args[0], args[1], args[2]], args[3], Helper.getVarargs(args, 4, pts[1]));
						}
					}
					if(Helper.isVarargs(args, 1, 2, t0, pts = [3], 0) && te(pts, 1)) {
						return foobar.__ks_1.call(that, [args[0], args[1]], args[2], Helper.getVarargs(args, 3, pts[1]));
					}
				}
				if(Helper.isVarargs(args, 2, 3, t0, pts = [2], 0) && te(pts, 1)) {
					return foobar.__ks_1.call(that, [args[0]], args[1], Helper.getVarargs(args, 2, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
		if(args.length === 6) {
			if(t1(args[0]) && t1(args[1]) && t1(args[2])) {
				if(t1(args[3])) {
					if(t0(args[4]) && t0(args[5])) {
						return foobar.__ks_1.call(that, [args[0], args[1], args[2]], args[3], [args[4], args[5]]);
					}
				}
				if(t0(args[3]) && t0(args[4]) && t0(args[5])) {
					return foobar.__ks_1.call(that, [args[0], args[1]], args[2], [args[3], args[4], args[5]]);
				}
			}
			throw Helper.badArgs();
		}
		if(args.length === 7) {
			if(t1(args[0]) && t1(args[1]) && t1(args[2]) && t1(args[3]) && t0(args[4]) && t0(args[5]) && t0(args[6])) {
				return foobar.__ks_1.call(that, [args[0], args[1], args[2]], args[3], [args[4], args[5], args[6]]);
			}
		}
		throw Helper.badArgs();
	};
};