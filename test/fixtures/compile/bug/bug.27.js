const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function(foo, args) {
		let __ks_0;
		(__ks_0 = foo.bar(), __ks_0.qux).apply(__ks_0, [].concat(args));
	};
	corge.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return corge.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};