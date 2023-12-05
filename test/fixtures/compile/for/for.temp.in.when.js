const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		let value;
		for(let __ks_1 = 0, __ks_0 = Helper.length(x.foo); __ks_1 < __ks_0; ++__ks_1) {
			value = x.foo[__ks_1];
			let __ks_2;
			if(Type.isValue(__ks_2 = value.bar()) ? (value = __ks_2, true) : false) {
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