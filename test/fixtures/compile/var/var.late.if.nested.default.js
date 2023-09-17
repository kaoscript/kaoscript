const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		return 42;
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let x;
		let a = quxbaz.__ks_0();
		if(Type.isValue(a)) {
			if(a === 0) {
				x = -1;
			}
			else {
				x = a;
			}
		}
		else {
			x = 0;
		}
		return x + 2;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};