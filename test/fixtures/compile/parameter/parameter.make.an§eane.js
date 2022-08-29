const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		let __ks_0;
		if(x === void 0 || x === null) {
			__ks_0 = __ks_default_1.__ks_0();
			if(Type.isNotEmpty(__ks_0)) {
				x = __ks_0;
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function __ks_default_1() {
		return __ks_default_1.__ks_rt(this, arguments);
	};
	__ks_default_1.__ks_0 = function() {
		return null;
	};
	__ks_default_1.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_default_1.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};