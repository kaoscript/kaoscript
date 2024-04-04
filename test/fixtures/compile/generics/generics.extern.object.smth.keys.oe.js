const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		const keys = Object.keys(values);
		for(let __ks_1 = 0, __ks_0 = keys.length, key; __ks_1 < __ks_0; ++__ks_1) {
			key = keys[__ks_1];
			console.log(key);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};