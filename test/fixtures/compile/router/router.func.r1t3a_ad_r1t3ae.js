const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items, x, values) {
		if(x === void 0 || x === null) {
			x = 42;
		}
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, [args[0]], void 0, [args[1]]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					if(t0(args[2])) {
						return foobar.__ks_0.call(that, [args[0], args[1]], void 0, [args[2]]);
					}
				}
				if(t0(args[2])) {
					return foobar.__ks_0.call(that, [args[0]], args[1], [args[2]]);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 4) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					if(t0(args[2])) {
						if(t0(args[3])) {
							return foobar.__ks_0.call(that, [args[0], args[1], args[2]], void 0, [args[3]]);
						}
					}
					if(t0(args[3])) {
						return foobar.__ks_0.call(that, [args[0], args[1]], args[2], [args[3]]);
					}
				}
				if(t0(args[2]) && t0(args[3])) {
					return foobar.__ks_0.call(that, [args[0]], args[1], [args[2], args[3]]);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 5) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					if(t0(args[2])) {
						if(t0(args[4])) {
							return foobar.__ks_0.call(that, [args[0], args[1], args[2]], args[3], [args[4]]);
						}
					}
					if(t0(args[3]) && t0(args[4])) {
						return foobar.__ks_0.call(that, [args[0], args[1]], args[2], [args[3], args[4]]);
					}
				}
				if(t0(args[2]) && t0(args[3]) && t0(args[4])) {
					return foobar.__ks_0.call(that, [args[0]], args[1], [args[2], args[3], args[4]]);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 6) {
			if(t0(args[0]) && t0(args[1])) {
				if(t0(args[2])) {
					if(t0(args[4]) && t0(args[5])) {
						return foobar.__ks_0.call(that, [args[0], args[1], args[2]], args[3], [args[4], args[5]]);
					}
				}
				if(t0(args[3]) && t0(args[4]) && t0(args[5])) {
					return foobar.__ks_0.call(that, [args[0], args[1]], args[2], [args[3], args[4], args[5]]);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 7) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[4]) && t0(args[5]) && t0(args[6])) {
				return foobar.__ks_0.call(that, [args[0], args[1], args[2]], args[3], [args[4], args[5], args[6]]);
			}
		}
		throw Helper.badArgs();
	};
};