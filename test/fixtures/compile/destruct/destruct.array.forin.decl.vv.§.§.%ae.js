const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		for(let __ks_1 = 0, __ks_0 = values.length, line, element; __ks_1 < __ks_0; ++__ks_1) {
			Helper.assertDexArray(values[__ks_1], 1, 2, 0, Type.isValue);
			([line, element] = values[__ks_1]);
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