const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		let value, key;
		for(key in x.foo) {
			value = x.foo[key];
			let __ks_0;
			if(Type.isValue(__ks_0 = value.bar()) ? (value = __ks_0, true) : false) {
				console.log(key, value);
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