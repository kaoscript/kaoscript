const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		if(x === void 0) {
			x = null;
		}
		if(y === void 0) {
			y = null;
		}
		quxbaz.__ks_0(Type.isValue(x) ? x : Type.isValue(y) ? y : 42);
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 2) {
			return foobar.__ks_0.call(that, args[0], args[1]);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};