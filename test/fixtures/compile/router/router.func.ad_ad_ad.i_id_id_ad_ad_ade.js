const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c) {
		if(a === void 0 || a === null) {
			a = 0;
		}
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(c === void 0 || c === null) {
			c = 0;
		}
		return 0;
	};
	foobar.__ks_1 = function(x, y, z, a, b, c) {
		if(y === void 0 || y === null) {
			y = 0;
		}
		if(z === void 0 || z === null) {
			z = 0;
		}
		if(a === void 0 || a === null) {
			a = 0;
		}
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(c === void 0 || c === null) {
			c = 0;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_1.call(that, args[0], void 0, void 0, void 0, void 0, void 0);
			}
			return foobar.__ks_0.call(that, args[0], void 0, void 0);
		}
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_1.call(that, args[0], args[1], void 0, void 0, void 0, void 0);
				}
				return foobar.__ks_1.call(that, args[0], void 0, void 0, args[1], void 0, void 0);
			}
			return foobar.__ks_0.call(that, args[0], args[1], void 0);
		}
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					if(t1(args[2])) {
						return foobar.__ks_1.call(that, args[0], args[1], args[2], void 0, void 0, void 0);
					}
					return foobar.__ks_1.call(that, args[0], args[1], void 0, args[2], void 0, void 0);
				}
				return foobar.__ks_1.call(that, args[0], void 0, void 0, args[1], args[2], void 0);
			}
			return foobar.__ks_0.call(that, args[0], args[1], args[2]);
		}
		if(args.length === 4) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					if(t1(args[2])) {
						return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3], void 0, void 0);
					}
					return foobar.__ks_1.call(that, args[0], args[1], void 0, args[2], args[3], void 0);
				}
				return foobar.__ks_1.call(that, args[0], void 0, void 0, args[1], args[2], args[3]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 5) {
			if(t0(args[0]) && t1(args[1])) {
				if(t1(args[2])) {
					return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3], args[4], void 0);
				}
				return foobar.__ks_1.call(that, args[0], args[1], void 0, args[2], args[3], args[4]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 6) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
				return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3], args[4], args[5]);
			}
		}
		throw Helper.badArgs();
	};
};