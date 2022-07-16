const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, c) {
		quxbaz.__ks_0(x, null, c, null, x, x);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(a, b, c, d, e, f) {
		if(a === void 0) {
			a = null;
		}
		if(b === void 0) {
			b = null;
		}
		if(d === void 0) {
			d = null;
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 6) {
			if(t0(args[2]) && t0(args[4]) && t0(args[5])) {
				return quxbaz.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4], args[5]);
			}
		}
		throw Helper.badArgs();
	};
};