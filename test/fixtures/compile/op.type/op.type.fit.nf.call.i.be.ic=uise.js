const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return 42;
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
	quxbaz.__ks_0 = function(x) {
		return 0;
	};
	quxbaz.__ks_1 = function(x) {
		return 1;
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
		const t1 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_1.call(that, args[0]);
			}
			if(t1(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	quxbaz.__ks_0(foobar.__ks_0());
};