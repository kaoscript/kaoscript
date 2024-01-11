const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let x = quxbaz.__ks_0();
		if(test.__ks_0() === true && Type.isValue(x)) {
		}
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
		return 0;
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function() {
		return true;
	};
	test.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return test.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};