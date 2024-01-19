const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
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
	function value() {
		return value.__ks_rt(this, arguments);
	};
	value.__ks_0 = function() {
		return "";
	};
	value.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return value.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(value.__ks_0());
};