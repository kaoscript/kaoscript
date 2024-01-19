const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return [];
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		return [];
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const modifiers = quxbaz.__ks_0();
	modifiers.unshift(...quxbaz.__ks_0());
	const nodes = foobar.__ks_0();
	nodes.unshift(...foobar.__ks_0());
};