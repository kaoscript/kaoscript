const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value === void 0) {
			value = null;
		}
		let __ks_0, __ks_1;
		return (__ks_1 = quxbaz(value), Type.isValue(__ks_1) ? (__ks_0 = corge(__ks_1), Type.isValue(__ks_0) ? grault(__ks_0) : null) : null);
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};