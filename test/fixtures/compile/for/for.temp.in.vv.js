const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		for(let __ks_2 = x.values(), __ks_1 = 0, __ks_0 = Helper.length(__ks_2), __ks_x_1; __ks_1 < __ks_0; ++__ks_1) {
			__ks_x_1 = __ks_2[__ks_1];
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};