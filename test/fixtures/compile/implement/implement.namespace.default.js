const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Math = {};
	__ks_Math.foo = function() {
		return __ks_Math.foo.__ks_rt(this, arguments);
	};
	__ks_Math.foo.__ks_0 = function(x, y) {
		return x;
	};
	__ks_Math.foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_Math.foo.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};