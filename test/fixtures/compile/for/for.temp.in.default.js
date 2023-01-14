const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		if(Type.isValue(x.foo)) {
			for(let __ks_1 = 0, __ks_0 = x.foo.length, value; __ks_1 < __ks_0; ++__ks_1) {
				value = x.foo[__ks_1];
				console.log(value);
			}
		}
		if(Type.isValue(x.bar)) {
			for(let __ks_1 = 0, __ks_0 = x.bar.length, value; __ks_1 < __ks_0; ++__ks_1) {
				value = x.bar[__ks_1];
				console.log(value);
			}
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};