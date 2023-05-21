const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value === void 0) {
			value = null;
		}
		return Type.isValue(value) ? quxbaz.__ks_0(value) : null;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(value) {
		if(value === void 0) {
			value = null;
		}
		return value;
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return quxbaz.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};