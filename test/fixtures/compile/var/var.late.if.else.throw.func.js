const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let x;
		let __ks_0;
		if(Type.isValue(__ks_0 = quxbaz.__ks_0()) ? (x = __ks_0, true) : false) {
		}
		else {
			error.__ks_0();
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
		return null;
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function error() {
		return error.__ks_rt(this, arguments);
	};
	error.__ks_0 = function() {
		throw new Error();
	};
	error.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return error.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};