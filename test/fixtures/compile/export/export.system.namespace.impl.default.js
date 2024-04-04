const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Math = {};
	__ks_Math.pi = Math.PI;
	__ks_Math.foo = function() {
		return __ks_Math.foo.__ks_rt(this, arguments);
	};
	__ks_Math.foo.__ks_0 = function() {
		return Math.PI;
	};
	__ks_Math.foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Math.foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Number: {},
		__ks_Math
	};
};