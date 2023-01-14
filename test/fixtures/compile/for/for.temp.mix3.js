const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		if(Type.isValue(x.foo)) {
			for(let __ks_1 = 0, __ks_0 = x.foo.length, value; __ks_1 < __ks_0; ++__ks_1) {
				value = x.foo[__ks_1];
				let __ks_2 = value.kind;
				if(__ks_2 === 42) {
					let __ks_3, __ks_4, __ks_5, __ks_6;
					[__ks_3, __ks_4, __ks_5, __ks_6] = Helper.assertLoop(0, "", 0, "value.values.length", value.values.length, Infinity, "", 1);
					for(let __ks_7 = __ks_3, i; __ks_7 < __ks_4; __ks_7 += __ks_5) {
						i = __ks_6(__ks_7);
						console.log(value.values[i]);
					}
				}
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