const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c) {
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(c === void 0 || c === null) {
			c = 0;
		}
		return 0;
	};
	foobar.__ks_1 = function(a, b, c, d) {
		if(b === void 0 || b === null) {
			b = 0;
		}
		if(c === void 0 || c === null) {
			c = 0;
		}
		return 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0], void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_1.call(that, args[0], void 0, void 0, args[1]);
				}
				return foobar.__ks_0.call(that, args[0], args[1], void 0);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t0(args[2])) {
					return foobar.__ks_1.call(that, args[0], args[1], void 0, args[2]);
				}
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 4) {
			if(t0(args[0]) && t0(args[3])) {
				return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};