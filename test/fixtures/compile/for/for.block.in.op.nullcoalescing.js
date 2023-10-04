const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(values === void 0) {
			values = null;
		}
		for(let __ks_2 = Type.isValue(values) ? values : [0, 1, 2], __ks_1 = 0, __ks_0 = __ks_2.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = __ks_2[__ks_1];
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};