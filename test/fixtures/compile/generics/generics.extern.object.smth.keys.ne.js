const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(values === void 0) {
			values = null;
		}
		const keys = Object.keys(values);
		for(let __ks_1 = 0, __ks_0 = keys.length, key; __ks_1 < __ks_0; ++__ks_1) {
			key = keys[__ks_1];
			console.log(key);
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};