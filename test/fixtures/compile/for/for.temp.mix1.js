const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, y, z) {
		for(let __ks_1 = 0, __ks_0 = y.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = y[__ks_1];
			console.log(value);
		}
		for(let __ks_1 = 0, __ks_0 = z.length, value; __ks_1 < __ks_0; ++__ks_1) {
			value = z[__ks_1];
			console.log(value);
		}
		if(Type.isValue(x.bar)) {
			for(let key in x.bar) {
				let value = x.bar[key];
				console.log(key, value);
			}
			for(let key in x.bar) {
				let value = x.bar[key];
				console.log(key, value);
			}
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return foo.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};