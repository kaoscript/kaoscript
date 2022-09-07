const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Math = {};
	__ks_Math.foo = function() {
		return __ks_Math.foo.__ks_rt(this, arguments);
	};
	__ks_Math.foo.__ks_0 = function(x, y, z) {
		if(y === void 0) {
			y = null;
		}
		if(z === void 0 || z === null) {
			z = -1;
		}
		return Helper.concatString(x, ".", y, ".", z);
	};
	__ks_Math.foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length >= 2 && args.length <= 3) {
			if(t0(args[0])) {
				return __ks_Math.foo.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Math
	};
};