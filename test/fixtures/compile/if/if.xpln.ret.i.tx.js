const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function __ks_throw_1() {
		return __ks_throw_1.__ks_rt(this, arguments);
	};
	__ks_throw_1.__ks_0 = function() {
		throw new Error();
	};
	__ks_throw_1.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_throw_1.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return (x === true) ? 0 : __ks_throw_1.__ks_0();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};