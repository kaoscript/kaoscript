const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
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
	function quzbaz() {
		return quzbaz.__ks_rt(this, arguments);
	};
	quzbaz.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
		if(x === null) {
			x = 42;
		}
		foobar.__ks_0(x);
	};
	quzbaz.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return quzbaz.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};