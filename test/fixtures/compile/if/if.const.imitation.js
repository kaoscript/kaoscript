const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
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
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function() {
	};
	corge.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return corge.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let x = foobar.__ks_0();
	if(Type.isValue(x)) {
	}
	else if(Type.isValue((x = quxbaz.__ks_0()))) {
	}
	else if(Type.isValue((x = corge.__ks_0()))) {
	}
};