const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b = null, c) {
		console.log(a, b, c);
	};
	foobar.__ks_1 = function(a, b = null, c, d) {
		console.log(a, b, c, d);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					if(t0(args[2])) {
						return foobar.__ks_1.call(that, args[0], void 0, args[1], args[2]);
					}
				}
				if(t0(args[2])) {
					return foobar.__ks_0.call(that, args[0], args[1], args[2]);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 4) {
			if(t0(args[0]) && t1(args[2]) && t0(args[3])) {
				return foobar.__ks_1.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};